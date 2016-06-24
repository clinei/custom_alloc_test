#!/bin/bash
configs=("baseline" "freelist" "freetree");
for config in "${configs[@]}"; do
	dub test -b release --config="${config}" --compiler="${DC}";
done;
