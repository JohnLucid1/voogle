fn test_some(n1 int, n2 int) int {
	return n1 + n2
}

fn test_some1(n1 int, n2 int) int {
	return n1 + n2
}

fn test_some2(n1 string, n2 string) (string, string) {
	return n1, n2
}

fn (mut val Person) add_age() {
	val.age++
}

fn add_age(mut p Person) {
	p.age++
}

fn create_person(name string, age int) Person {
	return Person{
		name: name
		age: age
	}
}

struct Person {
mut:
	name string
	age  int
}
