using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerStomp : MonoBehaviour
{
    PlayerCtrl player;

    [SerializeField] Transform groundCheckObj;
    [SerializeField] float stompCheckRadius = 0.25f;
    [SerializeField] LayerMask enemyLayer;

    void Awake()
    {
        player = this.gameObject.GetComponent<PlayerCtrl>();
    }

    void Update()
    {
        if (IsStompingEnemy())
        {
            player.jumping.GroundJumpStart();
            player.stateMachine.TransitionTo(player.stateMachine.jumpingState);
        }
    }

    private bool IsStompingEnemy()
    {
        if (!player.collisions.IsGrounded && (player.stateMachine.CurrentState == player.stateMachine.fallingState || player.stateMachine.CurrentState == player.stateMachine.glidingState || player.stateMachine.CurrentState == player.stateMachine.wallSlidingState || player.stateMachine.CurrentState == player.stateMachine.wallClimbingState || player.stateMachine.CurrentState == player.stateMachine.wallVaultingState))
        {
            Collider2D[] colliders = Physics2D.OverlapCircleAll(groundCheckObj.position, stompCheckRadius, enemyLayer);
            return (colliders.Length > 0);
        }
        return false;
    }
}
