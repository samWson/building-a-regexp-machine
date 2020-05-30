"
# SWNfaTest

I am the test case for `SWNfa`.

The `factory` protocol methods of `SWNfa` can be considered a key public interface, therefore the `factory` protocol is targeted for test coverage.

## Instance Variables

- aOrBFixture: an example machine that accepts the characters 'a' or 'b'. Equivalent to the expression '(a|b)'
"
Class {
	#name : #SWNfaTest,
	#superclass : #TestCase,
	#instVars : [
		'aOrBFixture'
	],
	#category : #'SWRegularExpression-Tests'
}

{ #category : #'tests - fixture' }
SWNfaTest >> aOrBFixture [
	^ Dictionary new
		at: 1 at: SWNfa epsilonClosure put: {1 . 2 . 5} asSet;
		at: 2 at: $a put: {3} asSet;
		at: 2 at: SWNfa epsilonClosure put: {2} asSet;
		at: 3 at: SWNfa epsilonClosure put: {3 . 4} asSet;
		at: 4 at: SWNfa epsilonClosure put: {4} asSet;
		at: 5 at: $b put: {6} asSet;
		at: 5 at: SWNfa epsilonClosure put: {5} asSet;
		at: 6 at: SWNfa epsilonClosure put: {6 . 4} asSet;
		yourself
]

{ #category : #running }
SWNfaTest >> setUp [
	"Hooks that subclasses may override to define the fixture of test."
	super setUp.
	aOrBFixture := self aOrBFixture
]

{ #category : #tests }
SWNfaTest >> testCharactersFactory [

	| a |
	a := SWNfa character: $a.
	self 
		assert: (a test: 'a') equals: true;
		assert: (a test: '') equals: false;
		assert: (a test: 'aa') equals: false;
		assert: (a test: 'A') equals: false
]

{ #category : #tests }
SWNfaTest >> testConcatenationFactory [

	| a b c abc |
	a := SWNfa character: $a.
	b := SWNfa character: $b.
	c := SWNfa character: $c.
	
	abc := SWNfa concat: { a. b. c. }.
	
	self 
		assert: (abc test: 'abc') equals: true;
		assert: (abc test: ' abc') equals: false;
		assert: (abc test: 'abc ') equals: false;
		assert: (abc test: 'cba') equals: false;
		assert: (abc test: 'bac') equals: false;
		assert: (abc test: '') equals: false;
		assert: (abc test: 'aabc') equals: false;
		assert: (abc test: 'abcd') equals: false;
		assert: (abc test: 'Abc') equals: false
]

{ #category : #tests }
SWNfaTest >> testEpsilonFactory [

	| epsilonMachine |
	epsilonMachine := SWNfa emptyString.
	self 
		assert: (epsilonMachine test: '') equals: true;
		assert: (epsilonMachine test: 'a') equals: false;
		assert: (epsilonMachine test: ' a') equals: false;
		assert: (epsilonMachine test: 'a ') equals: false
]

{ #category : #tests }
SWNfaTest >> testKleeneClosureFactory [

	| a zeroOrMoreA |
	a := SWNfa character: $a .
	zeroOrMoreA := SWNfa repeat: a.
	
	self
		assert: (zeroOrMoreA test: '') equals: true;
		assert: (zeroOrMoreA test: 'a') equals: true;
		assert: (zeroOrMoreA test: 'aa') equals: true;
		assert: (zeroOrMoreA test: ' a') equals: false;
		assert: (zeroOrMoreA test: 'a ') equals: false;
		assert: (zeroOrMoreA test: 'A') equals: false;
		assert: (zeroOrMoreA test: 'b') equals: false

	
]

{ #category : #tests }
SWNfaTest >> testOneOrMoreFactory [

	| a oneOrMoreA |
	a := SWNfa character: $a.
	oneOrMoreA := SWNfa oneOrMore: a.
	
	self
		assert: (oneOrMoreA test: 'a') equals: true;
		assert: (oneOrMoreA test: 'aa') equals: true;
		assert: (oneOrMoreA test: '') equals: false;
		assert: (oneOrMoreA test: ' a') equals: false;
		assert: (oneOrMoreA test: 'a ') equals: false;
		assert: (oneOrMoreA test: 'ab') equals: false;
		assert: (oneOrMoreA test: 'aA') equals: false;
		assert: (oneOrMoreA test: 'A') equals: false
]

{ #category : #tests }
SWNfaTest >> testOneOrZeroFactory [

	| a oneOrZeroA |
	a := SWNfa character: $a.
	oneOrZeroA := SWNfa oneOrZero: a.
	
	self
		assert: (oneOrZeroA test: '') equals: true;
		assert: (oneOrZeroA test: 'a') equals: true;
		assert: (oneOrZeroA test: 'aa') equals: false;
		assert: (oneOrZeroA test: ' a') equals: false;
		assert: (oneOrZeroA test: 'a ') equals: false;
		assert: (oneOrZeroA test: '  ') equals: false;
		assert: (oneOrZeroA test: 'A') equals: false;
		assert: (oneOrZeroA test: 'b') equals: false
]

{ #category : #tests }
SWNfaTest >> testOrFactory [

	| aOrBOrC a b c |
	a := SWNfa character: $a.
	b := SWNfa character: $b.
	c := SWNfa character: $c.
	aOrBOrC := SWNfa or: { a. b. c. }.
	
	self
		assert: (aOrBOrC test: 'a') equals: true;
		assert: (aOrBOrC test: 'b') equals: true;
		assert: (aOrBOrC test: 'c') equals: true;
		assert: (aOrBOrC test: 'A') equals: false;
		assert: (aOrBOrC test: 'abc') equals: false;
		assert: (aOrBOrC test: ' a') equals: false;
		assert: (aOrBOrC test: 'b ') equals: false
]

{ #category : #tests }
SWNfaTest >> testTransitionTable [
	| a b aOrB |
	a := SWNfa character: $a.
	b := SWNfa character: $b.
	aOrB := SWNfa or: { a. b. }.
			
	self assert: aOrB transitionTable equals: self aOrBFixture
]
