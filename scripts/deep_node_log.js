const repl = require('repl');
const util = require('util');

const r = repl.start({
    useColors: true,
    writer: (output) => util.inspect(output, { depth: null, colors: true })
});

