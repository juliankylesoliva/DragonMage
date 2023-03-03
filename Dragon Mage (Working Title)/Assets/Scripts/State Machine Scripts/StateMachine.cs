using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public interface IState
{
    public void Enter();
    public void Update();
    public void Exit();
}

[System.Serializable]
public class StateMachine
{
    public IState CurrentState { get; private set; }

    public StandingState standingState;
    public RunningState runningState;
    // public JumpingState jumpingState;
    // public FallingState fallingState;

    public StateMachine(PlayerCtrl player)
    {
        // Initialize new states here with player reference
        standingState = new StandingState(player);
        runningState = new RunningState(player);
    }

    public void Initialize(IState startingState)
    {
        CurrentState = startingState;
        startingState.Enter();
    }

    public void TransitionTo(IState nextState)
    {
        CurrentState.Exit();
        CurrentState = nextState;
        nextState.Enter();
    }

    public void Update()
    {
        if (CurrentState != null) { CurrentState.Update(); }
    }
}
