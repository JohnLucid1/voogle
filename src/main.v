// voogle:
// Parses a v directory, takes all function names in types in funciton
// then on localhost search for function signatures
// Search sytnax: Returntype(param type, param type): int (string, string)

module main

import os
import math
// import encoding.utf8
import v.parser
import arrays
import v.ast
import v.pref
const cli_max = 10

// TODO: using treesitter SQL tables to go structs with json
// TODO: concurently search folders
// TODO: maybe create a mutex vec to add to it concurentrly
// TODO: How the fuck do you get return type of structs instead of fn (voidptr) bool
struct FnSignature {
	name        string
	file_path   string
	return_type string
	pos         int
	ln int
	params      []Param
mut:
	acc int = -1
}

fn (v FnSignature) println() {
	println('${v.file_path}${v.pos}${v.ln} $: ${v.name} :: ${v.params.map(it.type_)} score: ${v.acc}')
}

struct Param {
	type_  string
	is_mut bool
}

fn calc_distance(str1 string, str2 string) int {
	m := str1.len
	n := str2.len
	highest := math.max(n, m)
	mut dp := [][]int{len: highest + 1, init: []int{len: highest + 1}}

	for i := 0; i <= m; i++ {
		dp[i][0] = i
	}

	for j := 0; j <= n; j++ {
		dp[0][j] = j
	}

	for i := 1; i <= m; i++ {
		for j := 1; j <= n; j++ {
			if str1[i - 1] == str2[j - 1] {
				dp[i][j] = dp[i - 1][j - 1]
			} else {
				dp[i][j] = 1 + math.min(dp[i][j - 1], math.min(dp[i - 1][j], dp[i - 1][j - 1]))
			}
		}
	}

	return dp[m][n]
}

// THEN Serailize them with json
// Implement flag module in it
// Depenant on the flag, re-serialize directory or not
// TODO: make it a flag to search by cli
fn main() {
	// FIXME: This is a test of data, in future write a function that pulls all files with .v from directory that you get from cmd arguments
	// TODO: actually implement flags
	// start_directory := os.args[1]
	// filepaths := os.walk_ext(start_directory, '.v')
	// if filepaths.len == 0 {
	// 	eprintln("Starting directory doesn't contain any .v files")
	// 	return
	// }

	// for filepath in filepaths {
	// 	if !os.exists(filepath) {
	// 		eprintln('FILEPAHT DOES NOT EXIST')
	// 		return
	// 	}
	// }

	// table := ast.new_table()
	// prefs := pref.new_preferences()
	// _ := parser.parse_files(filepaths, table, prefs)

	// mut all_singnatures := []FnSignature{}
	// for _, fn_signature in table.fns {
	// 	res := parse_sig(fn_signature, table) or {
	// 		eprintln(err)
	// 		return
	// 	}
	// 	all_singnatures << res
	// }

	// all_singnatures.println()
	// println(calc_distance("main.TEst_some1", "main.test_some1"))

	// TEST: this is a test of cli

	start_directory := os.args[1]
	input := os.args[2]
	filepaths := os.walk_ext(start_directory, '.v')

	if filepaths.len == 0 {
		eprintln("Starting directory doesn't contain any .v files")
		return
	}

	for filepath in filepaths {
		if !os.exists(filepath) {
			println('happend there')
			eprintln('FILEPAHT DOES NOT EXIST')
			return
		}
	}

	table := ast.new_table()
	prefs := pref.new_preferences()
	_ := parser.parse_files(filepaths, table, prefs)

	mut all_singnatures := []FnSignature{}
	for _, fn_signature in table.fns {
		res := parse_sig(fn_signature, table) or { continue }
		all_singnatures << res
	}
	parse_cli(input, mut all_singnatures)
}

// TODO: Write init function that takes care of tables and so on
fn parse_cli(search_str string, mut fn_singatures []FnSignature) ? {
	ret, types := parse_input(search_str)
	println('ret: ${ret}, types: ${types}')
	parsed_types := types.trim("()").split(",")

	for mut sig in fn_singatures {
		ret_dist := calc_distance(ret, sig.return_type)
		types_dist := calc_array(parsed_types, sig.params.map(it.type_))
		sig.acc = ret_dist + types_dist
	}

	fn_singatures.sort(a.acc < b.acc)

	for i in 0 .. cli_max {
		fn_singatures[i].println()
	}
}

fn calc_array(arr1 []string, arr2[]string) int {
	mut dist := 0
	if arr1.len == arr2.len {
		for i, _ in arr1 {
			dist += calc_distance(arr1[i], arr2[i])	
		}
	}else {
		if arr1.len > arr2.len{
			for i, _ in arr2 {
				dist += calc_distance(arr1[i], arr2[i])	
			}			
		}else {
			for i, _ in arr1 {
				dist += calc_distance(arr1[i], arr2[i])	
			}			
		}
	}
	return dist
}

fn parse_input(search_str string) (string, string) {
	ret, types := search_str.split_once(' ') or { return '', '' }
	return ret, types
}

fn parse_sig(sig ast.Fn, table &ast.Table) ?FnSignature {
	if sig.name == 'main.main' {
		return none
	}
	toip := FnSignature{
		params: sig.params.map(Param{
			is_mut: it.is_mut
			type_: table.get_type_name(it.typ).to_lower()
		})
		file_path: sig.file
		pos: sig.pos.pos
		ln: sig.pos.line_nr
		name: sig.name.to_lower()
		return_type: table.get_type_name(sig.return_type).to_lower()
	}
	return toip
}
