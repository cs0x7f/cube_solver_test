
function nxopt() (
	cd cube20src
	cat ../dataset/$1.txt | \
	head -n10 | \
	./nxopt11 - | \
	awk '/Solved/ {
		cnt += 1;
		node += $8;
		tt += $(10);
		printf("%03d %.2fM nodes, %0.3f ns/node\n", $2 - 1, $8/1e6, $(10)*1e9/$8);
	} END {
		if (cnt > 0) printf("Avg %.2fM nodes, %0.3f ns/node\n", node/1e6/cnt, tt*1e9/node);
	}'
)

function vcube() (
	cd vcube
	cat ../dataset/$1.txt |\
	head -n10 |\
	./vc-optimal -c 104 -w 1 2>/dev/null |\
	awk '/^[0-9]/ {
		cnt += 1;
		node += $3;
		tt += $2;
		printf("%03d %.2fM nodes, %0.3f ns/node\n", $1, $3/1e6, $2*1e9/$3);
	} END {
		if (cnt > 0) printf("Avg %.2fM nodes, %0.3f ns/node\n", node/1e6/cnt, tt*1e9/node);
	}'
)

function reid() (
	cd reid
	(echo "R"; cat ../dataset/$1.txt) |\
	head -n11 |\
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
			printf("%03d %.2fM nodes, %0.3f ns/node\n", cnt - 2, $5/1e6, tinc*1e9/$5);
		}
	} END {
		if (cnt > 0) printf("Avg %.2fM nodes, %0.3f ns/node\n", node/1e6/cnt, tt*1e9/node);
	}'
)

nxopt random_move_15f
vcube random_move_15f
reid random_move_15f
