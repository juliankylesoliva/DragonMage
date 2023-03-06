using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerCamera : MonoBehaviour
{
    PlayerCtrl player;

    [SerializeField] Transform playerCamTarget;

    [SerializeField] float lookaheadDistance = 8f;
    [SerializeField] float fallingLookaheadDistance = 2f;
    [SerializeField] float fallingLookaheadThreshold = 0.1f;
    [SerializeField] float risingLookaheadDistance = 5f;
    [SerializeField] float risingLookaheadThreshold = 5f;
    [SerializeField] bool followCharacterOnJump = false;

    void Awake()
    {
        player = this.gameObject.GetComponent<PlayerCtrl>();
        playerCamTarget.position = player.collisions.groundCheckObj.position;
    }

    void Update()
    {
        UpdatePlayerCamTarget();
    }

    private void UpdatePlayerCamTarget()
    {
        if (player.form.isChangingForm) { return; }
        float horizontalLookahead = (lookaheadDistance * Mathf.Min(Mathf.Abs(player.rb2d.velocity.x / (player.movement.topSpeed * 2f)), 1f) * (player.rb2d.velocity.x >= 0f ? 1f : -1f));
        float initialYPos = (followCharacterOnJump || player.collisions.IsGrounded ? player.collisions.groundCheckObj.position.y : playerCamTarget.position.y);
        float fallingLookahead = (!player.collisions.IsGrounded && player.buffers.coyoteTimeLeft <= 0f && player.rb2d.velocity.y < 0f && player.collisions.groundCheckObj.position.y < (playerCamTarget.position.y - fallingLookaheadThreshold) ? fallingLookaheadDistance : 0f);
        float risingLookahead = (!player.collisions.IsGrounded && player.buffers.coyoteTimeLeft <= 0f && player.collisions.groundCheckObj.position.y > (playerCamTarget.position.y + risingLookaheadThreshold) ? risingLookaheadDistance * Mathf.Min(player.rb2d.velocity.y / (player.jumping.fallSpeed * 2f), 1f) : 0f);
        playerCamTarget.position = new Vector2(player.transform.position.x + horizontalLookahead, initialYPos + (player.rb2d.velocity.y > 0f ? risingLookahead : -fallingLookahead));
    }
}
