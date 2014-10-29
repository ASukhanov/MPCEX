# Load pedestal run sequence into sequencer 
Play_stapl.py i16 00000020 00110002 00200020 003000E0 00400020 00510008 00600060 00700020 00810003 009000A0 00A00030 00B00020 00C10038 00D00020 00E10100 00F00020 01012000 01100020 01220000 01300000 01400000 |./splayer_dump.py
# Enable all carriers and set carrier[0] as a master
Play_stapl.py i10 57333FC0 i12 0 i14 0 i20 0 i21 0 |./splayer_dump.py
# One shot
Play_stapl.py i16 4ff00000 i14 0 i20 0 i21 0 |./splayer_dump.py
# Check readback:
StaplPlayer -adumphdr dump_hdr.stp |./splayer_dump.py

# Continuous run
Play_stapl.py i16 2ff00000 i14 0 i20 0 i21 0 |./splayer_dump.py

echo "To repeat:"
echo "Play_stapl.py i10 57333FC0 i12 0 i14 0 i20 0 i21 0 |./splayer_dump.py"
echo "Play_stapl.py i16 4ff00000 i14 0 i20 0 i21 0 | ./splayer_dump.py"
echo "StaplPlayer -adumphdr dump_hdr.stp |./splayer_dump.py"


