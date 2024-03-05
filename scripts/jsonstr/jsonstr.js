const readline = require('readline');
const JSON5 = require('json5');

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout,
});

let inputJsLike = '';

// Read input from stdin line by line and accumulate it
rl.on('line', function(line) {
  inputJsLike += line + '\n'; // Preserve newlines
});

function preprocessJsonDates(input) {
  // Regular expression to match ISO 8601 date strings
  const dateRegex = /(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}Z)/g;
  // const dateRegex = /(?<![:'"]\s*['"]?)(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}Z)/g;


  // Replace date-like strings with quoted strings to ensure they are treated as strings
  return input.replace(dateRegex, '"$1"');
}

// When all lines have been read, parse the accumulated input
rl.on('close', function() {
  try {
    // if the input is valid json, just format it
    const json = JSON.parse(inputJsLike);
    return JSON.stringify(json, null, 2);
  } catch (error) {
    // ignore
  }

  try {
    // input probably is and object
    const preprocessed = preprocessJsonDates(inputJsLike);
    const parsedObj = JSON5.parse(preprocessed);
    const jsonStr = JSON.stringify(parsedObj, null, 2);

    // now remove the dates that were actually inside strings
    const regex = /\\\"(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}Z)\\\"/g;
    const result = jsonStr.replace(regex, '$1');
    console.log(result);
  } catch (error) {
    console.error('Error parsing input:', error);
  }
});
