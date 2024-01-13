module main

import term
import os
import flag
import v.scanner
import math
import v.parser
import v.ast
import v.pref

// TODO: Search on diff scopes
struct FnSignature {
	name        string
	file_path   string
	return_type string
	ln          int
	params      []Param
mut:
	acc int = -1
}

fn (v FnSignature) println() {
	println('${term.bright_yellow(v.file_path)} ${term.green(v.name)} :: ${v.params.map(term.blue(it.type_))} RETURNS: ${term.red(v.return_type)}')
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

fn main() {
	mut fp := flag.new_flag_parser(os.args)
	fp.application("voogle")
	fp.version("v0.0.1")
	fp.description("A tool to search v functions by types")
	path := fp.string('p', 0, "./", "Set filepath or dir to start searching")
	input := fp.string('i', 0, "", "Search query\n ")
	if input.len < 1 {
		println(fp.usage())
		return 
	}

	if os.is_file(path){

		table := ast.new_table()
		prefs := pref.new_preferences()
		_ := parser.parse_file(path, table, scanner.CommentsMode.skip_comments, prefs)

		mut all_singnatures := []FnSignature{}
		for _, fn_signature in table.fns {
			res := parse_sig(fn_signature, table) or { continue }
			all_singnatures << res
		}
		parse_cli(input, mut all_singnatures)
	} else {
		filepaths := os.walk_ext(path, '.v')

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
}

fn parse_cli(search_str string, mut fn_singatures []FnSignature) ? {
	ret, types := parse_input(search_str)
	println('Searching for Return type: ${ret}, Parameter types: ${types}')
	parsed_types := types.trim(' ').split(',')
	println("\n")

	for mut sig in fn_singatures {
		ret_dist := calc_distance(ret, sig.return_type)
		types_dist := calc_array(parsed_types, sig.params.map(it.type_))
		sig.acc = ret_dist + types_dist
	}

	fn_singatures.sort(a.acc < b.acc)

	for i in 0 ..  fn_singatures.len {
		fn_singatures[i].println()
	}
}

fn calc_array(arr1 []string, arr2 []string) int {
	mut dist := 0
	if arr1.len == arr2.len {
		for i, _ in arr1 {
			dist += calc_distance(arr1[i], arr2[i])
		}
	} else {
		if arr1.len > arr2.len {
			for i, _ in arr2 {
				dist += calc_distance(arr1[i], arr2[i])
			}
		} else {
			for i, _ in arr1 {
				dist += calc_distance(arr1[i], arr2[i])
			}
		}
	}
	return dist
}

fn parse_input(search_str string) (string, string) {
	mut ret, types := search_str.split_once('|') or { '', '' }
	if ret == " " || ret == "" { // NOTE: maybe change to if_empty() ??
		ret = "void"
	}
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
		ln: sig.pos.line_nr + 1
		name: sig.name.to_lower()
		return_type: table.get_type_name(sig.return_type).to_lower()
	}
	return toip
}
