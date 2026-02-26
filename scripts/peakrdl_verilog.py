# thanks Cam
import sys
from systemrdl import RDLCompiler, RDLCompileError
from peakrdl.verilog import VerilogExporter

input_file = "regmap/wedgetail_spi.rdl"

rdlc = RDLCompiler()

try:
    rdlc.compile_file(input_file)
    root = rdlc.elaborate()
except RDLCompileError:
    sys.exit(1)

# Default Template uses a hardcoded ADDR_WIDTH. Calculate the address here and
# then pass it into the VerilogExpoter as a user defined context variable.
# This is then inserted into the Jinja Template using {{ADDR_WIDTH}}.
def get_max_address(node):
    max_addr = 0
    for inst in node.children():
        addr = inst.absolute_address
        size = inst.size  # total_byte_size
        max_addr = max(max_addr, addr + size - 1)
    return max_addr

max_address = get_max_address(root)
address_width = max_address.bit_length()
print("Address Width =", address_width)

exporter = VerilogExporter(
    user_template_context={
        "ADDR_WIDTH": address_width
    }
)

exporter.export(root, "src", signal_overrides={})
