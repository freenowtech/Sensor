import Foundation
import Path
import GenerateDocsComponentLib

// -----------------------------------------
// Parameters
// -----------------------------------------

// This should be the docs folder
let currentDirectoryPath = Path.cwd

// The path where the components will be generated
let outputPath = Path.cwd/"GeneratedDocs"

// The playground for which we'll generate the docs component.
let playgroundPath = Path.cwd/"../Docs/SensorDocs.app/Contents/MacOS/SensorDocs.playground"
let playgroundPagesPath = playgroundPath/"Pages"

// -----------------------------------------
// Script
// -----------------------------------------

print("Playground: \(playgroundPath)")
print("Output path: \(outputPath)")

// Remove contents of output folder and create it again
try! outputPath.delete()
try! outputPath.mkdir(.p)

let playgroundPages = playgroundPagesPath.find().extension("swift")

let pages = playgroundPages.map(parseFile)
    .sorted { $0.title < $1.title }

let renderedPages = render(pages)

renderedPages.forEach { try! $0.content.write(to: outputPath/"\($0.fileName)") }
