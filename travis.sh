#!/bin/bash
configs=("baseline" "freelist" "freetree");
for config in "${configs[@]}"; do
	dub test --config="${config}" --compiler="${DC}";
done;
