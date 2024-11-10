// Todo:
// - Load function, load from JSON and ADD, not replace to the list.
// - Save function, opposite of load, save current task list to a JSON file.

import Foundation
import Glibc
import Table

enum CommandlineToken {
    case Quit,
        Print,
        Add,
        Remove,
        Change,
        Help,
        Invalid
}

struct Time {
    var date: [Int]
    var time: [Int]
}

struct Task {
    let timeOfCreation: String
    var title: String
    var description: String
    var deadline: String?

    init(title: String, description: String, deadline: String?) {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy HH:mm"
        formatter.locale = Locale(identifier: "en_UK")

        let formattedDateTime =
            formatter
            .string(from: Date())

        self.description = description
        self.title = title
        self.deadline = deadline
        self.timeOfCreation = formattedDateTime
    }

    mutating func changeTitle(newTitle: String) {
        self.title = newTitle
    }

    mutating func changeDeadline(newDeadline: String?) {
        self.deadline = newDeadline
    }

    mutating func changeDescription(newDescription: String) {
        self.description = newDescription
    }
}

struct TaskList {
    var tasks: [Task]

    mutating func addTask(task: Task) {
        tasks.append(task)
    }

    mutating func removeTask(idx: Int) {
        tasks.remove(at: idx)
    }

    func printTable() {
        var data = [["Index", "Title", "Description", "Deadline", "Created"], []]

        for (idx, it) in self.tasks.enumerated() {
            let deadline = it.deadline ?? "None"

            data[1].append(contentsOf: [
                String(idx), it.title, it.description, deadline, it.timeOfCreation,
            ])
        }

        let table = try! Table(data: data).table()

        print(table)
    }
}

func ask(_ prompt: String = "-> ", terminator: String = " ") -> String? {
    print(prompt, terminator: terminator)

    return readLine()
}

func commandLine() -> (CommandlineToken, [String]) {
    print("->", terminator: " ")

    if let line = readLine() {
        let token =
            switch line
                .components(separatedBy: " ")[0]
                .lowercased()
            {
            case "change":
                CommandlineToken.Change
            case "remove":
                CommandlineToken.Remove
            case "add":
                CommandlineToken.Add
            case "print":
                CommandlineToken.Print
            case "quit", "exit":
                CommandlineToken.Quit
            case "help":
                CommandlineToken.Help
            default:
                CommandlineToken.Invalid
            }

        return (token, Array(line.components(separatedBy: " ").dropFirst()))
    }

    return (CommandlineToken.Invalid, [])
}

func parseCommandToken(command: (CommandlineToken, [String]), taskList: inout TaskList) {
    switch command.0 {
    case CommandlineToken.Help:
        print(
            """
            Commands:
                print                     - Prints the tasklist as a table.
                help                      - Prints this message.
                add                       - Add a task, you'll be prompted soon about properties.
                remove <index>            - Removes a task at that index.
                change <index> <property> - Changes a property of the indexed task.

            Properties:
                deadline
                title
                description
            """)
    case CommandlineToken.Quit:
        exit(0)
    case CommandlineToken.Print:
        taskList.printTable()
    case CommandlineToken.Add:
        let desiredTitle = ask("What would you like as your title?")!
        let desiredDescription = ask("What would you like as your description?")!
        let desiredDeadline = ask(
            "What would you like as your deadline? If you'd like none, click enter. Otherwise use this format: 23:28 10/03/2024. "
        )
        taskList.addTask(
            task: Task.init(
                title: desiredTitle, description: desiredDescription, deadline: desiredDeadline))
    case CommandlineToken.Remove:
        taskList.removeTask(idx: Int(command.1.first!)!)
    case CommandlineToken.Change:
        switch (command.1[1]).lowercased() {
        case "deadline":
            let desiredDeadline = ask(
                "What would you like as your deadline? If you'd like none, click enter. Otherwise use this format: 23:28 10/03/2024. "
            )
            taskList.tasks[Int(command.1[0])!].deadline = desiredDeadline
        case "description":
            let desiredDescription = ask("What would you like as your description?")!
            taskList.tasks[Int(command.1[0])!].description = desiredDescription
        case "title":
            let desiredTitle = ask("What would you like as your title?")!
            print(command.1)
            taskList.tasks[Int(command.1[0])!].title = desiredTitle
        default:
            print(
                "Couldn't get that property, please refer to the properties listed in the `help` command and try again."
            )

        }
        print()
    case CommandlineToken.Invalid:
        print("Failed parsing that command, try again or enter `help`.")
    }
}

func main() {
    let anotherTask = Task.init(
        title: "Testing Title", description: "Test Description", deadline: Optional.none)
    var aList = TaskList.init(tasks: [anotherTask])

    while true {
        parseCommandToken(command: commandLine(), taskList: &aList)
    }
}

main()
