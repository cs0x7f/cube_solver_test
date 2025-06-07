#!/bin/bash

if [ -z $ntest ]; then
	ntest=10
fi

if [ -z $nthread ]; then
	nthread=1
fi

function nxopt() (
	echo "test nxopt$2 $1"
	dataset=$(pwd)/dataset/$1.txt
	cd cube20src
	cat $dataset | head -n$ntest |\
	./nxopt$2 -t $nthread - |\
	awk '/Solved/ {
		cnt += 1;
		node += $8;
		tt += $(10);
		printf("%03d %.3fM nodes, %0.3f ns/node\n", $2 - 1, $8/1e6, $(10)*1e9/$8/'$nthread');
		system("");
	} END {
		if (cnt > 0) printf("Avg %.3fM nodes, %0.3f ns/node, tt=%0.3fs\n\n", node/1e6/cnt, tt*1e9/node/'$nthread', tt/cnt/'$nthread');
	}'
)

function vcube() (
	echo "test vcube$2 $1"
	dataset=$(pwd)/dataset/$1.txt
	cd vcube
	cat $dataset | head -n$ntest |\
	./vc-optimal -c $2 -w $nthread 2>/dev/null |\
	awk '/^[0-9]/ {
		cnt += 1;
		node += $3;
		tt += $2;
		printf("%03d %.3fM nodes, %0.3f ns/node\n", $1, $3/1e6, $2*1e9/$3/'$nthread');
		system("");
	} END {
		if (cnt > 0) printf("Avg %.3fM nodes, %0.3f ns/node, tt=%0.3fs\n\n", node/1e6/cnt, tt*1e9/node/'$nthread', tt/cnt/'$nthread');
	}'
)

function reid() (
	echo "test reid $1"
	dataset=$(pwd)/dataset/$1.txt
	cd reid
	(echo "R"; cat $dataset | head -n$ntest) |\
	sed "s/1/ /g" | sed "s/3/'/g" |\
	./twist |\
	awk 'v==1 {print; v=0;} /:/ {v=1}' |\
	./solve |\
	awk '@load "time"; /solution found/ {
		cnt += 1;
		if (cnt == 1) {
			tref = gettimeofday();
		} else {
			gsub(",", "", $5);
			node += $5
			tinc = gettimeofday() - tref;
			tref = gettimeofday();
			tt += tinc;
			printf("%03d %.3fM nodes, %0.3f ns/node\n", cnt - 2, $5/1e6, tinc*1e9/$5);
			system("");
		}
	} END {
		if (cnt > 0) printf("Avg %.3fM nodes, %0.3f ns/node, tt=%0.3fs\n\n", node/1e6/cnt, tt*1e9/node, tt/cnt);
	}'
)

function h48() (
	echo "test h48$2 $1"
	dataset=$(pwd)/dataset/$1.txt
	cd h48
	./build python
	cat $dataset | head -n$ntest |\
	python3 cmd.py h48$2k2 $nthread 2>&1 |\
	awk '/Nodes visited/ {
		cnt += 1;
		node += $5;
		curnode = $5;
	} /^Time/ {
		tt += $2;
		curtt = $2;
		printf("%03d %.3fM nodes, %0.3f ns/node\n", cnt - 1, curnode/1e6, curtt*1e9/curnode);
		system("");
	} END {
		if (cnt > 0) printf("Avg %.3fM nodes, %0.3f ns/node, tt=%0.3fs\n\n", node/1e6/cnt, tt*1e9/node, tt/cnt);
	}'
)

function cubeopt() (
	echo "test cube$3$2 $1"
	dataset=$(pwd)/dataset/$1.txt
	cd ../cubeopt
	cat $dataset | head -n$ntest |\
	./cube$3$2 -t $nthread - |\
	awk '/finished/ {
		split($5, s, "/");
		split($7, t, "=");
		cnt += 1;
		node += s[1];
		tt += t[2] / 1000;
		printf("%03d %.3fM nodes, %0.3f ns/node\n", cnt - 1, s[1]/1e6, t[2]*1e6/s[1]);
		system("");
	} END {
		if (cnt > 0) printf("Avg %.3fM nodes, %0.3f ns/node, tt=%0.3fs\n\n", node/1e6/cnt, tt*1e9/node, tt/cnt);
	}'
)

function kocpy() (
	echo "test kocpy $1"
	dataset=$(pwd)/dataset/$1.txt
	cd RubiksCube-OptimalSolver
	cat $dataset | head -n$ntest |\
	head -n$ntest |\
	pypy3 cmd.py |\
	awk '/total time/ {
		cnt += 1;
		node += $7;
		tt += $3;
		printf("%03d %.3fM nodes, %0.3f ns/node\n", cnt - 1, $7/1e6, $3*1e9/$7);
		system("");
	} END {
		if (cnt > 0) printf("Avg %.3fM nodes, %0.3f ns/node, tt=%0.3fs\n\n", node/1e6/cnt, tt*1e9/node, tt/cnt);
	}'
)

function stickersolve() (
	echo "test stickersolve $1"
	dataset=$(pwd)/dataset/$1.txt
	cd ../stickersolve/build
	cat $dataset | head -n$ntest |\
	head -n$ntest |\
	../stickersolve -t $nthread - 2>/dev/null |\
	awk '/Solution found/ {
		split($5, s, "/");
		split($7, t, "=");
		cnt += 1;
		node += $4;
		tt += $7;
		printf("%03d %.3fM nodes, %0.3f ns/node\n", cnt - 1, $4/1e6, $7*1e6/$4);
		system("");
	} END {
		if (cnt > 0) printf("Avg %.3fM nodes, %0.3f ns/node, tt=%0.3fs\n\n", node/1e6/cnt, tt*1e3/node, tt/cnt);
	}'
)

function runtest() {
	if [[ "$1" =~ ^nxopt([0-9]{2})$ ]]; then
		nxopt $2 ${BASH_REMATCH[1]}
	elif [[ "$1" =~ ^vcube([0-9]{3})$ ]]; then
		vcube $2 ${BASH_REMATCH[1]}
	elif [[ "$1" =~ ^reid$ ]]; then
		reid $2
	elif [[ "$1" =~ ^kocpy$ ]]; then
		kocpy $2
	elif [[ "$1" =~ ^stickersolve$ ]]; then
		stickersolve $2
	elif [[ "$1" =~ ^h48(h[0-9]{1,2})$ ]]; then
		h48 $2 ${BASH_REMATCH[1]}
	elif [[ "$1" =~ ^cubeopt([0-9]{2})$ ]]; then
		cubeopt $2 ${BASH_REMATCH[1]} "opt"
	elif [[ "$1" =~ ^cube48opt([0-9]{1,2})$ ]]; then
		cubeopt $2 ${BASH_REMATCH[1]} "48opt"
	elif [[ "$1" =~ ^cubenp([0-9]{2})$ ]]; then
		cubeopt $2 ${BASH_REMATCH[1]} "np"
	fi
}

mkdir -p results/

runtest $1 $2 | tee results/"$1"_"$nthread"_"$2".txt

# runtest nxopt11 random_move_15f
# runtest vcube104 random_move_15f
# runtest h48h0 random_move_15f
# runtest kocpy random_move_15f
# runtest reid random_move_15f
# ntest=500 nthread=12 bash runtest.sh vcube112 random_move_16f

