import Pkg

# parse command-line parameters
if length(ARGS) < 5
    println("Usage: octree.jl <input dir> <output dir> <levels> <channel> <voxelsize: x,y,z>")
    exit(1)
end

frompath = ARGS[1]
topath = ARGS[2]
nlevels = parse(Int,ARGS[3])
channel = parse(Int,ARGS[4])
voxelsize_um = map(x->parse(Float64,x), split(ARGS[5], ","))

  
import OctreeBuilder

OctreeBuilder.build_octree(frompath, topath, nlevels, channel)
OctreeBuilder.write_result(topath, voxelsize_um, nlevels)
