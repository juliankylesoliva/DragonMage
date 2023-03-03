using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RunningState : IState
{
    private PlayerCtrl player;

    public RunningState(PlayerCtrl player) { this.player = player; }

    public void Enter()
    {
        Debug.Log("Entered running state!");
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
        Debug.Log("Exited running state!");
    }
}
