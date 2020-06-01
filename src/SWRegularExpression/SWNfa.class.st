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
singleCharNfa := SWNfa character: $a.
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

For an NFA that allows one or more character transitions e.g. `a+`:

```smalltalk
a := SWNfa character: $a.
aPlus := SWNFa oneOrMore: a.

aPlus test: 'a'. ""true""
aPlus test: 'aa'. ""true""
aPlus test: ''. ""false""
``` 

For an NFA that allows one or zero character transitions i.e. is optional e.g. `a?`:

```smalltalk
a := SWNfa character: $a.
aOptional := SWNfa oneOrZero: a.

aOptional test: ''. ""true""
aOptional test: 'a'. ""true""
aOptional test: 'aa'. ""false""
```

#### Concatenation

State machines can be concatenated together into compound state machines.
To create a state machine that accepts `ab`:

```smalltalk
firstNfa := SWNfa character: $a.
secondNfa := SWNfa character: $b.
abNfa := SWNfa concat: firstNfa with: secondNfa.
abNfa test: 'ab'. ""true""
abNfa test: 'ac'. ""false""
```

An arbitrary number of state machines can be concatenated together in
order. Ordering is the same as array index ordering. To create a state 
machine that accepts `abc`:

```smalltalk
firstNfa := SWNfa character: $a.
secondNfa := SWNfa character: $b.
thirdNfa := SWNfa character: $c.

abcNfa := SWNfa concat: { firstNfa. secondNfa. thirdNfa. }.
abcNfa test: 'abc'. ""true""
abcNfa test: 'aba'. ""false""
```

#### Union

State machines can be combined into compound **OR** machines that accept 
one of two possible characters. To make a machine that accepts `a` or `b`:

```smalltalk
firstNfa := SWNfa character: $a.
secondNfa := SWNfa character: $b.

aOrBNfa := SWNfa or: firstNfa with: secondNfa.
aOrBNfa test: 'a'. ""true""
aOrBNfa test: 'b'. ""true""
aOrBNfa test: 'c'. ""false""
```

An arbitrary number of machines can be combined into a compound **OR**
machine by providing them in an `Array`. To make a machine that accepts
`a` or `b` or `c`:

```smalltalk
firstNfa := SWNfa character: $a.
secondNfa := SWNfa character: $b.
thirdNfa := SWNfa character: $c.

aOrBNfa := SWNfa or: { firstNfa. secondNfa. thirdNfa. }.
aOrBNfa test: 'a'. ""true""
aOrBNfa test: 'b'. ""true""
aOrBNfa test: 'c'. ""true""
aOrBNfa test: 'd'. ""false""
```

#### Repetition

State machines can be repeated zero or more times with the **Klenne-closure** operation. To create a machine that accepts zero or more instances of `a`:

```smalltalk
singleA := SWNfa character: $a.

repeatedA := SWNfa repeat: singleA.

repeatedA test: ''. ""true""
repeatedA test: 'a'. ""true""
repeatedA test: 'aa'. ""true""
repeatedA test: 'b'. ""false""
```

## Instance Variables

- alphabet: Set, all the symbols that I allow transitions for. Excludes ε.
- inState: SWState, my starting state.
- outState: SWState, my accepting state.
- transitionTable: Dictionary, a table of all possible transitions between my states.

## Class Variables

- Epsilon: The greek lower case ε. Represents an empty string.
- EpsilonClosure: An epsilon with the Kleene-closure applied: 'ε*'. Represents all possible epsilon transitions from a state inculding the state itself.
"
Class {
	#name : #SWNfa,
	#superclass : #Object,
	#instVars : [
		'inState',
		'outState',
		'transitionTable',
		'alphabet'
	],
	#classVars : [
		'Epsilon',
		'EpsilonClosure'
	],
	#category : #SWRegularExpression
}

{ #category : #factory }
SWNfa class >> character: aCharacter [
	
	| inState outState |
	inState := SWState newAccepting: false.
	outState := SWState newAccepting: true.

	inState addTransitionForSymbol: aCharacter state: outState.
	
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

	^ self character: self epsilon
]

{ #category : #constants }
SWNfa class >> epsilon [

	^ Epsilon
]

{ #category : #constants }
SWNfa class >> epsilonClosure [
	
	^ EpsilonClosure
]

{ #category : #'class initialization' }
SWNfa class >> initialize [

	Epsilon := $ε.
	EpsilonClosure := 'ε*'
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
SWNfa class >> oneOrZero: aSWNfa [
	"The question mark `?` operator. Allow an NFA transition one or zero times i.e. optional."	

	aSWNfa inState addEpsilonTransitionTo: aSWNfa outState.
	
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
SWNfa >> alphabet [

	^ alphabet 
		ifNil: [ | symbols |
			
			symbols := self transitionTable values flatCollectAsSet: [ :transition | transition keys ].
				
			alphabet := symbols copyWithout: self class epsilonClosure.
			alphabet
			 ] 
		ifNotNil: [ alphabet ]
]

{ #category : #accessing }
SWNfa >> appendEpsilonClosures: table visited: visited [

	visited do: [ :state | | labels |
		labels := state epsilonClosure collect: [ :each | each label ] as: Set.
	
		table at: state label at: self class epsilonClosure put: labels 
		]
]

{ #category : #'transitions - private' }
SWNfa >> appendSymbolTransitions: aDictionary state: aSWState visited: aSet [

	^ (aSet includes: aSWState) 
		ifTrue: [ 
			aDictionary
			] 
		ifFalse: [ 
			aSet add: aSWState.
			aSWState label: aSet size.
			
			aSWState transitions associationsDo: [ :transition | | stateLabels |
					
				stateLabels := transition value collect: [ :nextState | 
					self appendSymbolTransitions: aDictionary state: nextState visited: aSet.
					nextState label.
					] as: Set.
				
				aDictionary at: aSWState label at: transition key put: stateLabels.
				 ].
			
			aDictionary.
			 ]
]

{ #category : #'transitions - private' }
SWNfa >> buildTransitionTable [

	| table visited |
	visited := Set new.
	
	table := self appendSymbolTransitions: Dictionary new state: inState visited: visited.
	
	self appendEpsilonClosures: table visited: visited.

	self removeEpsilonTransitions: table.

	^ table
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

{ #category : #accessing }
SWNfa >> removeEpsilonTransitions: table [
	
	table valuesDo: [ :transition | transition removeKey: self class epsilon ifAbsent: [  ] ]
]

{ #category : #matching }
SWNfa >> test: aString [
	"Match the state to the test string."
	self flag: #todo. "After the course is finished consider renaming to `#match:`."
		
	^ inState test: aString
]

{ #category : #accessing }
SWNfa >> transitionTable [
	^ transitionTable
		ifNil: [ 
			transitionTable := self buildTransitionTable.
			transitionTable 
			]
		ifNotNil: [ transitionTable ]
]
