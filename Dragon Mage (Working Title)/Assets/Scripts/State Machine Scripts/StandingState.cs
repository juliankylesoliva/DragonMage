using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class StandingState : IState
{
    private PlayerCtrl player;

    public StandingState(PlayerCtrl player) { this.player = player; }

    public void Enter()
    {
        Debug.Log("Entered standing state!");
    }

    public void Update()
    {
        if (Input.GetButton("Jump"))
        {
            // player.stateMachine.TransitionTo(player.stateMachine.jumpState);
        }
        else if (Input.GetAxisRaw("Horizontal") != 0f)
        {
            player.stateMachine.TransitionTo(player.stateMachine.runningState);
        }
        else { }
    }

    public void Exit()
    {
        Debug.Log("Exited standing state!");
    }
}
