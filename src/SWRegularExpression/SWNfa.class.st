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
singleCharNfa := SWNfa singleCharacter: $a.
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

{ #category : #'instance creation' }
SWNfa class >> emptyString [

	^ self singleCharacter: self epsilon
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

{ #category : #'instance creation' }
SWNfa class >> singleCharacter: aCharacter [
	"Return a state machine that accepts a single character."
	
	| inState outState |
	inState := SWState newAccepting: false.
	outState := SWState newAccepting: true.
	
	inState addTransitionForSymbol: aCharacter state: outState.
	
	^ self newInState: inState outState: outState
]

{ #category : #accessing }
SWNfa >> inState: aSWState [

	inState := aSWState
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
