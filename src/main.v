// voogle:
// Parses a v directory, takes all function names in types in funciton
// then on localhost search for function signatures
// Search sytnax: Returntype(param type, param type): int (string, string)

module main

import os
import v.parser
import v.ast
import v.pref

// TODO: using treesitter SQL tables to go structs with json
// TODO: concurently search folders
// TODO: maybe create a mutex vec to add to it concurentrly
// TODO: How the fuck do you get return type of structs instead of fn (voidptr) bool

struct FnSignature {
	name        string
	file_path   string
	return_type string
	pos         int
	col         int
	params      []Param
}

struct Param {
	type_  string
	is_mut bool
}

// TODO: Walk a directory, get each file that ends with .v, and parse them :) 
// THEN Serailize them with json
// Implement flag module in it
// Depenant on the flag, re-serialize directory or not

fn main() {
	// FIXME: This is a test of data, in future write a function that pulls all files with .v from directory that you get from cmd arguments
	// TODO: actually implement flags
	start_directory := os.args[1]
	filepaths := os.walk_ext(start_directory, ".v")
	if filepaths.len  == 0 {
		eprintln("Starting directory doesn't contain any .v files")
		return 
	}

	for filepath in filepaths {
		if !os.exists(filepath) {
			eprintln('FILEPAHT DOES NOT EXIST')
			return
		}
	}

	table := ast.new_table()
	prefs := pref.new_preferences()
	_ := parser.parse_files(filepaths, table, prefs)

	mut all_singnatures := []FnSignature{}
	for _, fn_signature in table.fns {
		res := parse_sig(fn_signature, table) or {
			eprintln(err)
			return
		}
		all_singnatures << res
	}

	all_singnatures.println()
}


fn (sigs []FnSignature) println() {
	for sig in sigs {
		println("\n$sig.file_path, $sig.name, $sig.return_type\n$sig.params")
	}
}

// TODO: SHould get type from ast
// TODO: write a cli that searches types:
// TODO: Test if i even need to change struct type to Person from main.Person
fn parse_sig(sig ast.Fn, table &ast.Table) ?FnSignature {
	toip := FnSignature{
		params: sig.params.map(Param{
			is_mut: it.is_mut
			type_: table.get_type_name(it.typ)
		})
		file_path: sig.file
		pos: sig.pos.pos
		col: sig.pos.col
		name: sig.name
		return_type: table.get_type_name(sig.return_type)
	}
	return toip
}
