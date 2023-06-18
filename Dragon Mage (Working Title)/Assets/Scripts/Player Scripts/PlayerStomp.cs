using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerStomp : MonoBehaviour
{
    PlayerCtrl player;

    [SerializeField] Transform groundCheckObj;
    [SerializeField] float stompCheckRadius = 0.25f;
    [SerializeField] float highestYVelocity = 0.5f;
    [SerializeField] LayerMask enemyLayer;
    [SerializeField] DamageType damageType = DamageType.STOMP;

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
        if (!player.damage.isPlayerDamaged && !player.collisions.IsGrounded && !player.collisions.IsOnASlope && !player.attacks.isBlastJumpActive && !player.attacks.isFireTackleActive && (player.stateMachine.CurrentState == player.stateMachine.fallingState || player.stateMachine.CurrentState == player.stateMachine.glidingState || player.stateMachine.CurrentState == player.stateMachine.wallSlidingState || player.stateMachine.CurrentState == player.stateMachine.wallClimbingState || player.stateMachine.CurrentState == player.stateMachine.wallVaultingState || player.rb2d.velocity.y <= highestYVelocity))
        {
            Collider2D[] colliders = Physics2D.OverlapCircleAll(groundCheckObj.position, stompCheckRadius, enemyLayer);
            if (colliders.Length > 0)
            {
                Vector3 feetPos = groundCheckObj.position;
                Vector3 targetPos = colliders[0].transform.position;
                float heightDiff = (feetPos.y - targetPos.y);

                if (heightDiff > 0f)
                {
                    GameObject tempObj = colliders[0].gameObject;
                    EnemyBehavior tempEnemy = tempObj.GetComponent<EnemyBehavior>();
                    if (tempEnemy != null) { tempEnemy.DefeatEnemy(damageType); }
                    return true;
                }
            }
        }
        return false;
    }
}
