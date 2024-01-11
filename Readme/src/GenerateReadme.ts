import * as fs from "fs";
import * as ejs from "ejs";
import * as imageSize from "image-size";

const repoRoot = __dirname + "/../../";
const readmePath = repoRoot + `README.md`;

function pascalCaseToWords(input: string): string {
  return input.replace(/([A-Z][a-z]+)/g, (match, p1, offset) =>
    offset > 0 ? ` ${p1}` : p1
  );
}

interface Story {
  name: string;
  nameAsWords: string;
  codeSnippet: string;
  imageName: string;
  imageWidth: number;
  imageHeight: number;
}

function formatMultilineString(input: string): string {
  let lines = input.split("\n");

  while (lines.length > 0 && lines[0].trim() === "") {
    lines.shift();
  }
  while (lines.length > 0 && lines[lines.length - 1].trim() === "") {
    lines.pop();
  }

  let minLeadingSpaces = lines.reduce((min, line) => {
    if (line.trim() === "") {
      return min;
    }
    const leadingSpaces = line.search(/\S|$/);
    return Math.min(min, leadingSpaces);
  }, Infinity);

  if (minLeadingSpaces !== Infinity) {
    lines = lines.map((line) => line.substring(minLeadingSpaces));
  }
  return lines.join("\n");
}

function storiesFromFile(
  filePath: string,
  snapshotsFolderPath: string
): Story[] {
  const sourceCode = fs.readFileSync(repoRoot + filePath, "utf-8");

  const codeSnippetRegex =
    /func\s+story_(?<name>[A-Za-z0-9_]+)\(\)\s*->\s*UIView\s*{(?<codeSnippet>[\s\S]*?)return/g;

  const result: Story[] = [];
  let match;
  while ((match = codeSnippetRegex.exec(sourceCode)) !== null && match.groups) {
    let storyName = match.groups["name"];
    let imageName = `${snapshotsFolderPath}/test_${storyName}__default@3x.png`;
    let size = imageSize.imageSize(repoRoot + imageName);
    let imageWidth = size.width ?? 0;
    let imageHeight = size.height ?? 0;
    result.push({
      name: storyName,
      nameAsWords: pascalCaseToWords(match.groups["name"]),
      codeSnippet: formatMultilineString(match.groups["codeSnippet"]),
      imageName: imageName,
      imageWidth: imageWidth,
      imageHeight: imageHeight,
    });
  }

  return result;
}

(function () {
  const stories: Story[] = storiesFromFile(
    "FixFlexSamples/FixFlexSamples/Stories/FixFlexStories.swift",
    "FixFlexSamples/Ref/ReferenceImages_64/FixFlexSamplesTests.FixFlexTests"
  );

  if (fs.existsSync(readmePath)) {
    fs.rmSync(readmePath);
  }

  fs.writeFileSync(
    readmePath,
    ejs.render(fs.readFileSync(__dirname + "/templates/README.md", "utf-8"), {
      stories: stories,
    })
  );
})();
