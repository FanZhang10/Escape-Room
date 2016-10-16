/*
SWI-Prolog requires us to declare as dynamic any predicates that may change.
Also retract all existing statements in the knowledge base, for easier restart.
*/

:- dynamic i_am_at/1, at/2, holding/1, turn_on/1, turn_off/1, eat_food/1.
:- retractall(at(_, _)),
	retractall(i_am_at(_)),
	retractall(holding(_)),
	retractall(turn_on(_)),
	retractall(turn_off(_)),
	retractall(eat_food(_)).

/*
start is the first rule we will run when grading your game. Anything you want to be
seen first should go in here. This one just prints out where you currently are in
the world.
*/

start :- instructions , look.

/*
World Setup
*/
instructions  :-
	nl,
		write('Night, you prepare going to sleep,'), nl,
        write('suddenly the power is shut down,'), nl,
        write('everywhere is dark now,'), nl,
        write('you need to find your baby, he is crying!!'), nl, nl,
        write('Enter commands using standard Prolog syntax.'), nl,
        write('Available commands are:'), nl,
        write('instructions.			-- to start the game.'), nl,
        write('move(Dir).				-- to go in that direction.'), nl,
        write('pickup(Object).          -- to pick up an object.'), nl,
        write('drop(Object).            -- to put down an object.'), nl,
        write('eat(Object).             -- to eat an object.'), nl,
        write('look.                    -- to look around you again.'), nl,
        write('turnon(Object).	        -- to control the lights.'), nl,
		write('turnoff(Object).	        -- to control the lights.'), nl,
        nl,
	look.


path(bridge, e, office).	%there is a path from the bridge to the office moving east
path(office, n, garden).
path(office, s, diningroom).
path(garden, s, office).
path(bathroom, w, diningroom).
path(diningroom, n, laundryroom).
path(diningroom, s, bedroom).
path(diningroom, e, bathroom).
path(diningroom, w, kitchen).
path(laundryroom, s, diningroom).
path(bedroom, n, diningroom).
path(bedroom, e, livingroom).
path(bedroom, w, kidsroom).
path(living, w, bedroom).
path(kidsroom, e, bedroom).
path(kitchen, e, diningroom).
path(kitchen, n, basement).

at(office, flashlight).	%there is a communicator object in the office
at(diningroom, milk).
at(kitchen, apple).
at(livingroom, toys).
at(kidsroom, baby).
at(garden, dog).

turn_off(flashlight).
check(flashlight).
food(milk).
food(apple).

count_n(X) :- X is X.

i_am_at(bridge).			%player's initial location

/*
Verbs
*/

%Move - if the movement is valid, move the player.
move(Dir) :- %conditional movement
	i_am_at(kitchen),
	path(kitchen, Dir, basement),
	holding(flashlight),
	turn_on(flashlight),
	retract(i_am_at(kitchen)),
	assert(i_am_at(basement)),
	write('You have moved to '), write(basement), write('.'), nl,
	look,
	lose,
	!.

move(Dir) :- %conditional movement
	i_am_at(kitchen),
	path(kitchen, Dir, basement),
	write('Can not move to'), write(basement), write(','), nl,
	write('Please find flashlight and turn on it').
	look,
	!.

move(Dir) :- %conditional movement
	i_am_at(bedroom),
	path(bedroom, Dir, kidsroom),
	holding(milk),
	retract(i_am_at(bedroom)),
	assert(i_am_at(kidsroom)),
	write('You have moved to '), write(kidsroom), write('.'), nl,
	look,
	win,
	!.

move(Dir) :- %conditional movement
	i_am_at(bedroom),
	path(bedroom, Dir, kidsroom),
	write('Can not move to'), write(kidrooms), write(','), nl,
	write('Please find milk, your baby are hungry.').
	look,
	!.

move(Dir) :-
	i_am_at(X),
	path(X, Dir, Y),
	retract(i_am_at(X)),
	assert(i_am_at(Y)),
	write('You have moved to '), write(Y), write('.'), nl,
	look,
	!.

%Move - otherwise, tell the player they can't move.
move(_) :-
	write('You cannot move that direction.'), nl.

%Pick up object - if already holding the object, can't pick it up!
pickup(X) :-
	holding(X),
	write('You are already holding it!'), nl,
	!.

%Pick up object - if in the right location, pick it up and remove it from the ground.
pickup(X) :-
	i_am_at(Place),
	at(Place, X),
	retract(at(Place, X)),
	assert(holding(X)),
	write('You have picked it up.'), nl,
	look,!.

%Pick up object - otherwise, cannot pick up the object.
pickup(_) :-
	write('I do not see that here.'), nl.

drop(X) :-
        holding(X),
        i_am_at(Place),
        retract(holding(X)),
        assert(at(Place, X)),
        write('OK.'),
        nl,look,!.

drop(_) :-
        write('You aren''t holding it!'),
        nl.

turnon(X) :-
	check(X),
	holding(X),
	turn_off(X),
	retract(turn_off(X)),
	assert(turn_on(X)),
	write('The lights come on.'), nl,
	look,
	!.

turnon(_) :-
	write('The lights are already on.'), nl.

turnoff(X) :-
	check(X),
	holding(X),
	turn_on(X),
	retract(turn_on(X)),
	assert(turn_off(X)),
	write('It is now dark in here.'),
	nl,look,!.

turnoff(_) :-
	write('The lights are already off.'), nl.



eat(X) :-
	food(apple),
	holding(apple),
	assert(eat_food(apple)),
	write('It taste good.'), nl,!.

eat(X) :-
	food(apple),
	holding(apple),
	assert(eat_food(apple)),
	retract(holding(apple)),
	write('It taste good.'), nl,
	write('but no more left'), nl,!.


eat(X) :-
	food(X),
	holding(X),
	assert(eat_food(X)),
	write('It taste good.'), nl,!.

eat(_) :-
	write('Did you pick up somethings?'), nl.


%Look - describe where in space the player is, list objects at the location
look :-
	i_am_at(X),
	describe(X),
	list_objects_at(X).

%List objects - these two rules effectively form a loop that go through every object
%				in the location and writes them out.
list_objects_at(X) :-
	at(X, Obj),
	write('There is a '), write(Obj), write(' on the ground.'), nl,
	fail.

list_objects_at(_).

lose :-
        nl,
        write('NOOOOOOO! the door is locked, you lose.'),
        nl.
win :-
        nl,
        write('Yeah, you find your baby, let''s give him some milk you win.'),
        nl.

describe(X) :-
	write('You are in '), write(X), nl,
	able_path(X),nl.


able_path(X) :-
        path(X, D, Y),
	write('enter '),write(D),write(', You can go to '), write(Y), nl, fail.

able_path(_).



