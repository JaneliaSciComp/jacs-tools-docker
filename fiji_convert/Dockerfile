FROM janeliascicomp/fiji:fiji-openjdk-8

COPY fiji_macros /opt/fiji/Fiji.app/macros
COPY fiji_plugins /opt/fiji/Fiji.app/plugins

ENTRYPOINT [ "/opt/fiji/entrypoint.sh", "-macro", "convert_stack.ijm" ]

