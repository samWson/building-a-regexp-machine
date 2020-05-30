"
# SWStateTest

I am an the test case for `SWState`.
"
Class {
	#name : #SWStateTest,
	#superclass : #TestCase,
	#category : #'SWRegularExpression-Tests'
}

{ #category : #tests }
SWStateTest >> testAddTransitionForSymbol [

	| actual expected state1 state2 |
	state1 := SWState newAccepting: false.
	state2 := SWState newAccepting: true.
	
	state1 addTransitionForSymbol: $a state: state2.
	
	actual := state1 transitionsForSymbol: $a.
	expected := Dictionary new at: $a put: (OrderedCollection newFrom: { state2 }); yourself.
	
	self assert: actual equals: expected
]

{ #category : #tests }
SWStateTest >> testEpsilonClosure [

	| state1 state2 state3 state4 |
	state1 := SWState newAccepting: false.
	state2 := SWState newAccepting: false.
	state3 := SWState newAccepting: false.
	state4 := SWState newAccepting: false.
	
	state1 
		addTransitionForSymbol: $a state: state2;
		addEpsilonTransitionTo: state3;
		addEpsilonTransitionTo: state4.
		
	self assertCollection: state1 epsilonClosure hasSameElements: { state1. state3. state4. }
	
]
