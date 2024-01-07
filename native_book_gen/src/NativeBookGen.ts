import * as fs from "fs";
import * as ejs from "ejs";

const repoRoot = __dirname + "/../../";
const siteDir = repoRoot + "docs";

interface Story {
  name: string;
  codeSnippet: string;
}

interface Component {
  name: string;
  stories: Story[];
  snapshotsFolderPath: string;
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

function storiesFromFile(filePath: string): Story[] {
  const sourceCode = fs.readFileSync(repoRoot + filePath, "utf-8");

  const codeSnippetRegex =
    /func\s+story_(?<name>[A-Za-z0-9_]+)\(\)\s*->\s*UIView\s*{(?<codeSnippet>[\s\S]*?)return/g;

  const result: Story[] = [];
  let match;
  while ((match = codeSnippetRegex.exec(sourceCode)) !== null && match.groups) {
    result.push({
      name: match.groups["name"],
      codeSnippet: formatMultilineString(match.groups["codeSnippet"]),
    });
  }

  return result;
}

function renderIndex(components: Component[]) {
  fs.writeFileSync(
    siteDir + "/index.html",
    ejs.render(
      fs.readFileSync(__dirname + "/templates/index.html.ejs", "utf-8"),
      {
        components: components,
      }
    )
  );
}

function renderComponent(component: Component) {
  fs.writeFileSync(
    siteDir + `/${component.name}.html`,
    ejs.render(
      fs.readFileSync(__dirname + "/templates/component.html.ejs", "utf-8"),
      {
        component: component,
      }
    )
  );
}

(function () {
  // load config
  const nativeBookConfigContents = fs.readFileSync(
    repoRoot + "native_book_config.json",
    "utf-8"
  );

  const config = JSON.parse(nativeBookConfigContents);

  // gather information for a component
  const components: Component[] = [];
  for (const componentJson of config["components"]) {
    components.push({
      name: componentJson["name"],
      stories: storiesFromFile(componentJson["storiesFilePath"]),
      snapshotsFolderPath: componentJson["snapshotsFolderPath"],
    });
  }

  // prepare site folder
  if (fs.existsSync(siteDir)) {
    fs.rmSync(siteDir, { recursive: true });
  }

  fs.mkdirSync(siteDir, { recursive: true });

  // render html site
  renderIndex(components);
  for (const component of components) {
    fs.cpSync(
      repoRoot + component.snapshotsFolderPath,
      `${siteDir}/img/${component.name}`,
      {
        recursive: true,
      }
    );
    renderComponent(component);
  }
})();
