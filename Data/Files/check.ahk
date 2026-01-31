#SingleInstance force

param := A_Args[1]
if (!param) {
    ExitApp
}

file := % A_ScriptDir "\output.txt"
FileDelete, % file

Process, Exist, % param
pid := ErrorLevel
if (!pid) {
    ExitApp
}

FileAppend, % pid, % file