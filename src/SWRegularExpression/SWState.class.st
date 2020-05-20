"
# SWState

I represent a state in a State Machine.

## Usage

I have a class side method for instance creation `#newAccepting:`. It is given a
`Boolean` argument and will return an accepting or non-accepting state instance for
the given boolean.

```smalltalk
acceptingState := SWState newAccepting: true.
nonAcceptingState := SWState newAccepting: false.
```

## Instance Variables

- accepting: Boolean, sets if I am an accepting state or not.
- transitions: Dictionary, all transitions from me and the states they transition to.
  A transition points to a collection of states.
"
Class {
	#name : #SWState,
	#superclass : #Object,
	#instVars : [
		'accepting',
		'transitions'
	],
	#category : #SWRegularExpression
}

{ #category : #'instance creation' }
SWState class >> newAccepting: aBoolean [
 
	^ self new accepting: aBoolean
]

{ #category : #accessing }
SWState >> accepting: aBoolean [
 
	accepting := aBoolean
]

{ #category : #accesing }
SWState >> addEpsilonTransitionTo: aSWState [

	self addTransitionForSymbol: SWNfa epsilon state: aSWState
]

{ #category : #accesing }
SWState >> addTransitionForSymbol: aCharacter state: aState [

	transitions 
		at: aCharacter 
		ifPresent: [ :collection | collection add: aState ] 
		ifAbsent: [ transitions at: aCharacter put: (OrderedCollection newFrom: { aState. }) ]
]

{ #category : #initialization }
SWState >> initialize [

	transitions := Dictionary new
]

{ #category : #testing }
SWState >> isVisited: aSet [

	^ aSet includes: self
]

{ #category : #transitions }
SWState >> resolveAcceptingState: aSet [

	^ accepting
		ifTrue: [ true ]
		ifFalse: [ self transitionWithEpsilons: '' visited: aSet ]
]

{ #category : #transitions }
SWState >> test: aString [

	^ self test: aString visited: Set new
]

{ #category : #transitions }
SWState >> test: aString visited: aSet [

	(self isVisited: aSet) ifTrue: [ ^ false ].
	
	aSet add: self.

	^ aString isEmpty
		ifTrue: [ self resolveAcceptingState: aSet ]
		ifFalse: [ self transitionStates: aString visited: aSet ]
]

{ #category : #transitions }
SWState >> transitionStates: aString visited: aSet [

	^ (self transitionWithCharacters: aString) or: (self transitionWithEpsilons: aString visited: aSet)
]

{ #category : #transitions }
SWState >> transitionWithCharacters: aString [

	^ (self transitionsForSymbol: aString first) values 
		anySatisfy: [ :states | 
			states anySatisfy: [ :state | state test: aString allButFirst ] 
			]
]

{ #category : #transitions }
SWState >> transitionWithEpsilons: aString visited: aSet [
	
	^ (self transitionsForSymbol: SWNfa epsilon) values 
		anySatisfy: [ :states | 
			states anySatisfy: [ :state | state test: aString visited: aSet ] 
			]
]

{ #category : #accesing }
SWState >> transitionsForSymbol: aCharacter [
	
	^ transitions associationsSelect: [ :association | association key = aCharacter ]
]
