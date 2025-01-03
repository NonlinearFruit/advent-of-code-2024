def --wrapped main [...rest] {
  nu -c $'use toolkit.nu; toolkit ($rest | str join " ")'
}

# Download the puzzle input and description
export def "pull puzzle" [day:int] {
  mut day = $day | fill --alignment right --character '0' --width 2
  let year = date now | format date %Y
  let folder = find folder $day | default $"day-($day)"
  if ($folder | path exists) {
    aoc -y $year -d $day download --overwrite --input-file $"($folder)/input" --puzzle-file $"($folder)/README.md"
  } else {
    mkdir $folder
    aoc -y $year -d $day download --overwrite --input-file $"($folder)/input" --puzzle-file $"($folder)/README.md"

    open $"($folder)/README.md"
    | lines
    | first
    | parse -r '^\\--- Day \d+: (?<title>.*) ---$'
    | get title
    | first
    | str downcase
    | str replace ' ' '-'
    | $'($folder)-($in)'
    | mv $folder $in

    $'const input_file = "(find folder $day)/input"

export def "part 1" [] {
  open $input_file
}

export def "part 1 debug" [] {
  open $input_file
}

export def "part 2" [] {
  open $input_file
}

export def "part 2 debug" [] {
  open $input_file
}'
    | save $"(find folder $day)/mod.nu"
  }
}

# Submit an answer to a puzzle
export def "submit answer" [day:int] {
  mut day = $day | fill --alignment right --character '0' --width 2
  let year = date now | format date %Y
  let part = (find part $day)
  aoc -y $year -d $day submit $part (run puzzle $day)
}

# Run a puzzle solver
export def "run puzzle" [day:int] {
  mut day = $day | fill --alignment right --character '0' --width 2
  let folder = (find folder $day)
  let part = (find part $day)
  nu -c $"use ($folder); ($folder) part ($part)"
}

# Recalculate the README
export def "update readme" [] {
  let last_commit_badge = "[![GitHub last commit (branch)](https://img.shields.io/github/last-commit/NonlinearFruit/advent-of-code-2024/master)](https://github.com/NonlinearFruit/advent-of-code-2024/commits/master/)"
  let pipeline_badge = "[![GitHub Workflow Status (with event)](https://img.shields.io/github/actions/workflow/status/NonlinearFruit/advent-of-code-2024/test.yml?label=tests)](https://github.com/NonlinearFruit/advent-of-code-2024/actions/workflows/test.yml)"
  let star_count_badge = $"![star count]\(https://img.shields.io/badge/stars-(star count)-yellow)"
  let test_count_badge = $"![test count]\(https://img.shields.io/badge/tests-(test count)-blue)"

  $"
# Advent of Code 2024

($last_commit_badge)
($pipeline_badge)
($star_count_badge)
($test_count_badge)

```
(aoc calendar)
```
# Why Nushell

Nushell was placed on my radar in early 2023. My gut reaction was 'I hate powershell'. With some persistance from friends, the idea of Nushell was starting to take root. In the fall, it was time to put pen to paper and satiate my curiousity. Advent of Code 2023 \([source]\(https://github.com/NonlinearFruit/advent-of-code-2023)) was the testing ground. I learned a lot about Nushell and started using it day-to-day for scripting. The built-in testing framework was sunsetted at some point in 2024. That was a problem so I built nuUnit \([source]\(https://github.com/NonlinearFruit/nuUnit)).

This year when Advent of Code 2024 came around, I evaluated several other languages. In a proper familiar language, maybe I could complete all 25 days... It also could be a great chance to learn Clojure or Go... Practicing Lua or Python would be fun... But it was hard to resist battle testing nuUnit and pushing Nushell to it's limits. So I buckled in for another rocky ride exploring what Nushel is capable of.

# Prerequisites

```
cargo install nushell # https://github.com/nushell/nushell
cargo install aoc-cli # https://github.com/scarvalhojr/aoc-cli
vim ~/.adventofcode.session # https://github.com/scarvalhojr/aoc-cli?tab=readme-ov-file#session-cookie
```

# Usage
(docs)

## Nushell v0.100.0: Lessons Learned

- On day 2, when piping into an `if`, could not call a defined function in the `else` clause. The error was something like `variable not defined` but the stacktrace was a couple functions higher than the `else` clause
- nuUnit importing tests from a separate file doesn't work
- `open ~/tilde/path/from/home` doesn't work directly any more, `path expand` is necessary first
- Opening relative paths \(eg: `day-04-ceres-search/input`) is nuUnit tests is painful
  - Same with importing modules, it is difficult to know what kind of relative path to use \(eg: working directory, calling file's directory)
- A package manager of some sort is sorely needed. Being able to easily distribute and reuse code would be really helpful

# Links

- [Awesome Advent of Code]\(https://github.com/Bogdanp/awesome-advent-of-code) 
- [Reference when blocked]\(https://github.com/jromero132/advent-of-code) 
"
  | save -f README.md
}

def "find folder" [day:string] {
  ls
  | get name
  | where (str contains $day)
  | if ($in | is-empty) { null } else { first }
}

def "find part" [day:string] {
  let folder = find folder $day
  open $'($folder)/README.md'
  | if ($in | str contains 'Your puzzle answer was') {
    2
  } else {
    1
  }
}

def "test count" [] {
 0
}

def "star count" [] {
  aoc calendar
  | lines
  | where (str ends-with '*')
  | str replace -r '^.*?([*]+)$' '${1}'
  | str join
  | str length
}

def docs [] {
  help modules
  | where $it.name == toolkit
  | first
  | get commands.name
  | each {
    $"
<details>
<summary>
nu -c 'use toolkit.nu; toolkit ($in)'
</summary>

```
(help $in)
```
</details>"
  }
  | str join (char newline)
  | ansi strip
}
