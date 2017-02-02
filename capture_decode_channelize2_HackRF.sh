#!/bin/bash

#
# Add only the CA (Cell Allocation) according to SI type 1
#
CONFIGURATION="0B"
CA=""
C0=""
MA="0"
MAIO=0
HSN=0
KEY="00 00 00 00 00 00 00 00"
NSAMPLES=256000000

#############################################################

for x in $CA
do
  CA_FILES="$CA_FILES out/out_$x.cf"
done

minARFCN=`echo $CA | awk '{print $1}'`
maxARFCN=`echo $CA | awk '{print $NF}'`
c0POS=`echo $CA | awk -vchan=$C0 '{for(i=1;i<=NF;i++) if($i==chan)print (i-1)}'`
if [ x$c0POS == x ]
then
  echo "The main channel cannot be found in CA"
  exit
fi

ARFCN_fc=$((($maxARFCN+$minARFCN)/2))

if [ $ARFCN_fc -gt 125 ]
then
  FC=$((1805200000 + 200000*$(($ARFCN_fc-512))))
else
  FC=$((935000000 + 200000*$ARFCN_fc))
fi

BW=$((($maxARFCN-$minARFCN+1)*200))

if [ $BW -gt 10000 ]
then
  SR=20000000
  NCHANNELS=100
  pfbDECIM=16
  totDECIM=32
elif [ $BW -gt 200 ]
then
  SR=10000000
  NCHANNELS=50
  pfbDECIM=16
  totDECIM=64
elif [ $BW -le 200 ]
then
  SR=2500000
  NCHANNELS=1
  pfbDECIM=1
  totDECIM=16
fi

echo "min_ARFCN: $minARFCN"
echo "max_ARFCN: $maxARFCN"
echo "Center ARFCN: "$ARFCN_fc
echo "Center frequency: $FC"khz
echo "Sampling rate: $SR" 
echo "Number of samples: $NSAMPLES"
echo "CA files: $CA_FILES"
echo "C0 ARFCN: $C0"
echo "C0 position: $c0POS"
echo "SR: $SR"
echo "BW: $BW"
echo "NCHANNELS: $NCHANNELS"
echo "pfbDECIM: $pfbDECIM"
echo "totDECIM: $totDECIM"

if [ $CONFIGURATION == "0B" ]
then
	echo "***	Fase 1: Captura:"
	echo "		"
	hackrf_transfer -f $FC -s $SR -n $NSAMPLES -l 16 -g 14 -x 16 -r /tmp/arfcn117.bin
	echo 
	echo "***	Fase 1/2: conviertoformato..."
	echo
	/opt/hackrf/convert_s8_cfile.py --inputfile /tmp/arfcn117.bin

	echo "***	Fase 2: Filtro Polifasico"
	echo "		./channelize2.py --inputfile='out/out.cf' --arfcn='$ARFCN_fc' --srate='$SR' --decimation='$pfbDECIM' --nchannels='$NCHANNELS' --nsamples=$NSAMPLES"
 	./channelize2.py --inputfile="out/out.cf" --arfcn="$ARFCN_fc" --srate="$SR" --decimation="$pfbDECIM" --nchannels="$NCHANNELS" --nsamples=$NSAMPLES
	echo

	echo "***	Fase 3: Decodificar:"
	
	echo "		./gsm_receiveHackRF40_channelize.py -d '$totDECIM' -c '$CONFIGURATION' -k '$KEY' --c0pos $c0POS --ma '$MA' --maio $MAIO --hsn $HSN --inputfiles '$CA_FILES'"
	./gsm_receiveHackRF40_channelize.py -d "$totDECIM" -c "$CONFIGURATION" -k "$KEY" --c0pos $c0POS --ma "$MA" --maio $MAIO --hsn $HSN --inputfiles "$CA_FILES"
	echo

else
	echo "		./gsm_receiveHackRF40_channelize.py -d '$totDECIM' -c '$CONFIGURATION' -k '$KEY' --c0pos $c0POS --ma '$MA' --maio $MAIO --hsn $HSN --inputfiles '$CA_FILES'"
	./gsm_receiveHackRF40_channelize.py -d "$totDECIM" -c "$CONFIGURATION" -k "$KEY" --c0pos $c0POS --ma "$MA" --maio $MAIO --hsn $HSN --inputfiles "$CA_FILES"
fi

