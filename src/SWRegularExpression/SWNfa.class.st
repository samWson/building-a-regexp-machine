"
# SWNfa

I am a Non-deterministic Finite Automata (NFA) state machine.

## Usage

For instance creation use my class method `#newInState:outState:`. Both states
are manditory.

```smalltalk
state1 := SWState newAccepting: false.
state2 := SWState newAccepting: true.

stateMachine := SWNfa newInState: state1 outState: state2.
```

## Matching

For string pattern matching the instance method `#test:` is used to test if
this NFA matches the string.

```smalltalk
stateMachine test: 'A'
```

### Factory Methods

I have class factory methods that return specific types of state machines.

For a state machine that will only accept the character `a`:

```smalltalk
singleCharNfa := SWNfa characters: 'a'.
singleCharNfa test: 'a'. ""true""
singleCharNfa test: 'b'. ""false""
```

For a state machine that will only accept an empty string use the epsilon - ε
or empty string machine:

```smalltalk
epsilonNfa := SWNfa emptyString.
epsilonNfa test: ''. ""true""
epsilonNfa test: 'a'. ""false""
```

An NFA that supports multiple character transitions to the end state can be made
by providing a string of allowed characters. An entire character class can
be covered. For the character class of all numbers `[0-9]`:

```smalltalk
allNumbers := SWNfa characters: '0123456789'.

allNumbers test: '5'. ""true""
allNumbers test: '9'. ""true""
allNumbers test: 'a'. ""false""
```

For an NFA that allows one or more character transitions e.g. `a+`:

```smalltalk
a := SWNfa characters: 'a'.
aPlus := SNFa oneOrMore: a.

aPlus test: 'a'. ""true""
aPlus test: 'aa'. ""true""
aPlus test: ''. ""false""
``` 

#### Concatenation

State machines can be concatenated together into compound state machines.
To create a state machine that accepts `ab`:

```smalltalk
firstNfa := SWNfa characters: 'a'.
secondNfa := SWNfa characters: 'b'.
abNfa := SWNfa concat: firstNfa with: secondNfa.
abNfa test: 'ab'. ""true""
abNfa test: 'ac'. ""false""
```

An arbitrary number of state machines can be concatenated together in
order. Ordering is the same as array index ordering. To create a state 
machine that accepts `abc`:

```smalltalk
firstNfa := SWNfa characters: 'a'.
secondNfa := SWNfa characters: 'b'.
thirdNfa := SWNfa characters: 'c'.

abcNfa := SWNfa concat: { firstNfa. secondNfa. thirdNfa. }.
abcNfa test: 'abc'. ""true""
abcNfa test: 'aba'. ""false""
```

#### Union

State machines can be combined into compound **OR** machines that accept 
one of two possible characters. To make a machine that accepts `a` or `b`:

```smalltalk
firstNfa := SWNfa characters: 'a'.
secondNfa := SWNfa characters: 'b'.

aOrBNfa := SWNfa or: firstNfa with: secondNfa.
aOrBNfa test: 'a'. ""true""
aOrBNfa test: 'b'. ""true""
aOrBNfa test: 'c'. ""false""
```

An arbitrary number of machines can be combined into a compound **OR**
machine by providing them in an `Array`. To make a machine that accepts
`a` or `b` or `c`:

```smalltalk
firstNfa := SWNfa characters: 'a'.
secondNfa := SWNfa characters: 'b'.
thirdNfa := SWNfa characters: 'c'.

aOrBNfa := SWNfa or: { firstNfa. secondNfa. thirdNfa. }.
aOrBNfa test: 'a'. ""true""
aOrBNfa test: 'b'. ""true""
aOrBNfa test: 'c'. ""true""
aOrBNfa test: 'd'. ""false""
```

#### Repetition

State machines can be repeated zero or more times with the **Klenne-closure** operation. To create a machine that accepts zero or more instances of `a`:

```smalltalk
singleA := SWNfa characters: 'a'.

repeatedA := SWNfa repeat: singleA.

repeatedA test: ''. ""true""
repeatedA test: 'a'. ""true""
repeatedA test: 'aa'. ""true""
repeatedA test: 'b'. ""false""
```

## Instance Variables

- inState: SWState, my starting state.
- outState: SWState, my accepting state.

## Class Variables

- Epsilon: The greek lower case ε. Represents an empty string.
"
Class {
	#name : #SWNfa,
	#superclass : #Object,
	#instVars : [
		'inState',
		'outState'
	],
	#classVars : [
		'Epsilon'
	],
	#category : #SWRegularExpression
}

{ #category : #factory }
SWNfa class >> characters: aString [
	
	| inState outState |
	inState := SWState newAccepting: false.
	outState := SWState newAccepting: true.
	
	aString do: [ :char | inState addTransitionForSymbol: char state: outState ].
	
	^ self newInState: inState outState: outState
]

{ #category : #factory }
SWNfa class >> concat: aSequencableCollection [

	| concatenatedNfa |
	concatenatedNfa := aSequencableCollection first.

	aSequencableCollection allButFirstDo: [ :nfa | 
		concatenatedNfa := self concat: concatenatedNfa with: nfa
		].
	
	^ concatenatedNfa
]

{ #category : #factory }
SWNfa class >> concat: firstSWNfa with: secondSWNfa [

	firstSWNfa outState accepting: false.
	secondSWNfa outState accepting: true.
	
	firstSWNfa outState addEpsilonTransitionTo: secondSWNfa inState.

	^ self 
		newInState: firstSWNfa inState 
		outState: secondSWNfa outState
]

{ #category : #factory }
SWNfa class >> emptyString [
	
	self flag: #todo. "More correctly called the epsilon NFA. Allows transitions between state without consuming characters. Consider renaming."

	^ self characters: self epsilon asString
]

{ #category : #constants }
SWNfa class >> epsilon [

	^ Epsilon
]

{ #category : #'class initialization' }
SWNfa class >> initialize [

	Epsilon := $ε
]

{ #category : #'instance creation' }
SWNfa class >> newInState: aSWState1 outState: aSWState2 [

	^ self new
		inState: aSWState1;
		outState: aSWState2
]

{ #category : #factory }
SWNfa class >> oneOrMore: aSWNfa [
	"The plus `+` operator. Repeat an NFA one or more times."
	
	aSWNfa outState addEpsilonTransitionTo: aSWNfa inState.
	
	^ aSWNfa 
]

{ #category : #factory }
SWNfa class >> or: aSequencableCollection [

	| orNfa |
	orNfa := aSequencableCollection first.
	
	aSequencableCollection allButFirstDo: [ :nfa |
		orNfa := self or: orNfa with: nfa
		 ].
	
	^ orNfa
]

{ #category : #factory }
SWNfa class >> or: aSWNfa with: aSWNfa2 [

	| startState endState |
	startState := (SWState newAccepting: false)
		addEpsilonTransitionTo: aSWNfa inState;
		addEpsilonTransitionTo: aSWNfa2 inState;
		yourself.
	
	endState := SWState newAccepting: true.
	
	aSWNfa outState 
		accepting: false;
		addEpsilonTransitionTo: endState.
		
	aSWNfa2 outState 
		accepting: false;
		addEpsilonTransitionTo: endState.
	
	^ self newInState: startState outState: endState
]

{ #category : #factory }
SWNfa class >> repeat: aSWNfa [
	"The Kleene-closure or `*` operator. Repeat an NFA zero or more times."
	
	aSWNfa inState addEpsilonTransitionTo: aSWNfa outState.
	aSWNfa outState addEpsilonTransitionTo: aSWNfa inState.
	
	^ aSWNfa
]

{ #category : #accessing }
SWNfa >> inState [

	^ inState
]

{ #category : #accessing }
SWNfa >> inState: aSWState [

	inState := aSWState
]

{ #category : #accessing }
SWNfa >> outState [

	^ outState
]

{ #category : #accessing }
SWNfa >> outState: aSWState [

	outState := aSWState
]

{ #category : #tests }
SWNfa >> test: aString [
	"Match the state to the test string."
	self flag: #todo. "After the course is finished consider renaming to `#match:`."
		
	^ inState test: aString
]
