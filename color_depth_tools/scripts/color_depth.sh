#!/bin/bash

source ${COMMON_TOOLS_DIR}/setup_xvfb.sh
function exitHandler() { exitXvfb; cleanTemp; }
trap exitHandler EXIT

/opt/Fiji/ImageJ-linux64 -macro /opt/color_depth/fiji_macros/Color_Depth_MIP_batch_For_Pipeline.ijm "$@"
