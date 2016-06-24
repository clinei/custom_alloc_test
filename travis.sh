#!/bin/bash
configurations = ("baseline" "freelist" "freetree");
for conf in configurations; do
	dub test --config=${conf} --compiler=${DC};
done;
