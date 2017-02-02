#!/usr/bin/env python

import sys
import math
from gnuradio import gr, gru, eng_notation, blocks, filter 
from gnuradio.eng_option import eng_option
from gnuradio.wxgui import fftsink2
from gnuradio.wxgui import forms
from grc_gnuradio import wxgui as grc_wxgui
from optparse import OptionParser
import wx

class converter(gr.top_block):
    def __init__(self):
	gr.top_block.__init__(self)
		
        self.samp_rate = samp_rate = 32000

	#parse the options
        parser = OptionParser(option_class=eng_option)
        parser.add_option("--inputfile", type="string", default="/tmp/arfcn.bin", help="set the input file")
        (options, args) = parser.parse_args ()

        fichero_entrada = options.inputfile

        self.blocks_multiply_const_vxx_0 = blocks.multiply_const_vcc((1.0/128, ))
        self.blocks_interleaved_char_to_complex_0 = blocks.interleaved_char_to_complex(False)
        self.blocks_file_source_0 = blocks.file_source(gr.sizeof_char*1, fichero_entrada, False)
        self.blocks_file_sink_0 = blocks.file_sink(gr.sizeof_gr_complex*1, "/opt/airprobe-hopping/gsm-receiver/src/python/out/out.cf", False)
        self.blocks_file_sink_0.set_unbuffered(False)

        self.connect((self.blocks_file_source_0, 0), (self.blocks_interleaved_char_to_complex_0, 0))    
        self.connect((self.blocks_interleaved_char_to_complex_0, 0), (self.blocks_multiply_const_vxx_0, 0))    
        self.connect((self.blocks_multiply_const_vxx_0, 0), (self.blocks_file_sink_0, 0))    

    def get_samp_rate(self):
        return self.samp_rate

    def set_samp_rate(self, samp_rate):
        self.samp_rate = samp_rate


def main():
    try:
        converter().run()
    except KeyboardInterrupt:
        pass

if __name__ == '__main__':
    main()
