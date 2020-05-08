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

{ #category : #'as yet unclassified' }
SWState >> test: aString [ 
	self shouldBeImplemented.
]

{ #category : #accesing }
SWState >> transitionsForSymbol: aCharacter [
	
	^ transitions associationsSelect: [ :association | association key = aCharacter ]
]
