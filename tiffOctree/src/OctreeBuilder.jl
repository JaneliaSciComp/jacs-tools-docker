__precompile__(true)
module OctreeBuilder

using Images
using Printf

export build_octree

# load image from filename
load_data(filename) = rawview(channelview(load(filename)))

# save image to filename
function save_data(filename, data)
    @printf "Writing %s\n" filename
    save(filename, data)
end

# 2nd brightest of the 8 pixels
# equivalent to sort(vec(arg))[7] but half the time and a third the memory usage
function downsampling_function(arg::Array{UInt16,3})
    m0::UInt16 = 0x0000
    m1::UInt16 = 0x0000
    for i = 1:8
        @inbounds tmp::UInt16 = arg[i]
        if tmp > m0
            m1 = m0
            m0 = tmp
        elseif tmp > m1
            m1 = tmp
        end
    end
    m1
end

function downsample!(out_tile_jl, coord, shape_leaf_px, scratch)
    iy = ((coord - 1) >> 1) & 1 * shape_leaf_px[1] >> 1
    ix = ((coord - 1) >> 0) & 1 * shape_leaf_px[2] >> 1
    iz = ((coord - 1) >> 2) & 1 * shape_leaf_px[3] >> 1
    for z = 1:2:shape_leaf_px[3] - 1
        tmpz = iz + (z + 1) >> 1
        for x = 1:2:shape_leaf_px[2] - 1
            tmpx = ix + (x + 1) >> 1
            for y = 1:2:shape_leaf_px[1] - 1
                tmpy = iy + (y + 1) >> 1
                out_tile_jl[tmpy, tmpx, tmpz] = downsampling_function(scratch[y:y + 1, x:x + 1, z:z + 1])
            end
        end
    end
end
    
function build_octree(sourcefilename, targetpath, nlevels, channel)
    @printf "Loading image from %s\n" sourcefilename
    img = load_data(sourcefilename)
    
    @printf "Will generate octree with %d levels to %s\n" nlevels targetpath
    @printf "Image size: %s\n" size(img)

    # crop image to a power-of-two multiple of the octree leaf size
    dim = [size(img)[1:3]...]
    while(rem(dim[1], 2^(nlevels - 1)) > 0)  dim[1] -= 1;  end
    while(rem(dim[2], 2^(nlevels - 1)) > 0)  dim[2] -= 1;  end
    while(rem(dim[3], 2^(nlevels - 1)) > 0)  dim[3] -= 1;  end
    dim_leaf = [x >> (nlevels - 1) for x in dim]

    @printf "Adjusted image size: %s, Dim leaf: %s\n" dim dim_leaf

    function octree_division(relpath, img_down::Array{T,3}, img_view::SubArray{T,3}) where T <: UInt16
        morton = split(relpath, Base.Filesystem.path_separator)
        level = relpath == "" ? 1 : length(morton) + 1
        @printf "Level: %d, Current path: %s/%s\n" level targetpath relpath
        mkpath(joinpath(targetpath, relpath))
        if level < nlevels
            img_down_next = Array{T}(undef, dim_leaf...)
            dim_view = size(img_view)[1:3]
            for z = 1:2, y = 1:2, x = 1:2
                octant_path = string(x + 2 * (y - 1) + 4 * (z - 1))
                start_x = x == 1 ? 1 : dim_view[2] >> 1 + 1
                end_x = x == 1 ? dim_view[2] >> 1 : dim_view[2]
                start_y = y == 1 ? 1 : dim_view[1] >> 1 + 1
                end_y = y == 1 ? dim_view[1] >> 1 : dim_view[1]
                start_z = z == 1 ? 1 : dim_view[3] >> 1 + 1
                end_z = z == 1 ? dim_view[3] >> 1 : dim_view[3]
      
                @printf "octant:(%d,%d,%d) -> %s/%s (%d:%d, %d:%d, %d:%d)\n" x y z relpath octant_path start_x end_x start_y end_y start_z end_z
                octree_division(joinpath(relpath, octant_path), img_down_next, view(img_view, start_y:end_y, start_x:end_x, start_z:end_z))
            end
        end
        saveme = level == nlevels ? img_view : img_down_next
        filename = @sprintf "default.%d.tif" channel
        save_data(joinpath(targetpath, relpath, filename), saveme)
        if (level > 1)
            downsample!(img_down, parse(Int, morton[end]), dim_leaf, saveme)
            nothing
        end   
    end

    octree_division("", Array{eltype(img),3}(undef, dim_leaf...), view(img, 1:dim[1], 1:dim[2], 1:dim[3]))
end

function write_result(targetpath, voxelsize_um, nlevels)
    @printf "Write transform.txt to %s\n" targetpath
    fid = open(joinpath(targetpath, "transform.txt"), "w")
    println(fid, "ox: 10000")
    println(fid, "oy: 10000")
    println(fid, "oz: 10000")
    println(fid, "sx: ", voxelsize_um[1] * 2^(nlevels - 1))
    println(fid, "sy: ", voxelsize_um[2] * 2^(nlevels - 1))
    println(fid, "sz: ", voxelsize_um[3] * 2^(nlevels - 1))
    println(fid, "nl: ", nlevels)
    close(fid)
end

greet() = "Hello"  

end # module
