using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public interface IState
{
    public void Enter();
    public void Update();
    public void Exit();
}

/* STATE MACHINE */
[System.Serializable]
public class StateMachine
{
    public IState CurrentState { get; private set; }

    public StandingState standingState;
    public RunningState runningState;
    public JumpingState jumpingState;
    public FallingState fallingState;

    public StateMachine(PlayerCtrl player)
    {
        standingState = new StandingState(player);
        runningState = new RunningState(player);
        jumpingState = new JumpingState(player);
        fallingState = new FallingState(player);
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

/* STATES */
/*
 
TEMPLATE

public class VerbState : IState
{
    private PlayerCtrl player;

    public VerbState(PlayerCtrl player) { this.player = player; }

    public void Enter()
    {
        
    }

    public void Update()
    {
        
    }

    public void Exit()
    {
        
    }
}

 */


public class StandingState : IState
{
    private PlayerCtrl player;

    public StandingState(PlayerCtrl player) { this.player = player; }

    public void Enter()
    {
        
    }

    public void Update()
    {
        if (player.rb2d.velocity.y > 0f)
        {
            player.stateMachine.TransitionTo(player.stateMachine.jumpingState);
        }
        else if (Input.GetAxisRaw("Horizontal") != 0f)
        {
            player.stateMachine.TransitionTo(player.stateMachine.runningState);
        }
        else { }
    }

    public void Exit()
    {
        
    }
}

public class RunningState : IState
{
    private PlayerCtrl player;

    public RunningState(PlayerCtrl player) { this.player = player; }

    public void Enter()
    {
        
    }

    public void Update()
    {
        if (player.rb2d.velocity == Vector2.zero)
        {
            player.stateMachine.TransitionTo(player.stateMachine.standingState);
        }
    }

    public void Exit()
    {
        
    }
}

public class JumpingState : IState
{
    private PlayerCtrl player;

    public JumpingState(PlayerCtrl player) { this.player = player; }

    public void Enter()
    {

    }

    public void Update()
    {
        if (player.rb2d.velocity.y <= 0f)
        {
            player.stateMachine.TransitionTo(player.stateMachine.fallingState);
        }
    }

    public void Exit()
    {

    }
}

public class FallingState : IState
{
    private PlayerCtrl player;

    public FallingState(PlayerCtrl player) { this.player = player; }

    public void Enter()
    {

    }

    public void Update()
    {

    }

    public void Exit()
    {

    }
}
