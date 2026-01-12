const readline = require("readline");
const JSON5 = require("json5");

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout,
});

let inputJsLike = "";

// Read input from stdin line by line and accumulate it
rl.on("line", function(line) {
  inputJsLike += line + "\n"; // Preserve newlines
});

function preprocessJsonDatesAndFunctions(input) {
  // Regular expression to match ISO 8601 date strings
  const dateRegex = /(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}Z)/g;
  // Regular expression to match anonymous functions
  const functionRegex = /\[Function anonymous\]/g;

  const objectRegex = /\[Object\]/g;
  // Replace date-like strings with quoted strings to ensure they are treated as strings
  let preprocessed = input.replace(dateRegex, '"$1"');

  // Replace anonymous functions with a placeholder
  preprocessed = preprocessed.replace(
    functionRegex,
    '"[Function Placeholder]"',
  );
  preprocessed = preprocessed.replace(objectRegex, '"[Object]"');

  return preprocessed;
}

// When all lines have been read, parse the accumulated input
rl.on("close", function() {
  try {
    // If the input is valid JSON, just format it
    const json = JSON.parse(inputJsLike);
    console.log(JSON.stringify(json, null, 2));
    return;
  } catch (error) {
    // Ignore JSON parse errors and continue
  }

  try {
    // Input probably is an object
    const preprocessed = preprocessJsonDatesAndFunctions(inputJsLike);
    const parsedObj = JSON5.parse(preprocessed);
    const jsonStr = JSON.stringify(parsedObj, null, 2);

    // Now remove the dates that were actually inside strings
    const regex = /\\\"(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}Z)\\\"/g;
    const result = jsonStr.replace(regex, "$1");
    console.log(result);
  } catch (error) {
    console.error("Error parsing input:", error);
  }
});
