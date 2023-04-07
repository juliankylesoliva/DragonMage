using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerCollisions : MonoBehaviour
{
    PlayerCtrl player;

    public Transform groundCheckObj;
    public Transform[] wallChecksR;
    public Transform[] wallChecksL;
    public Transform headbonkCheckObj;
    public Transform normalCheckR;
    public Transform normalCheckL;

    [SerializeField] float groundCheckRadius = 0.1f;
    [SerializeField] float wallCheckRadius = 0.1f;
    [SerializeField] float headbonkCheckRadius = 0.5f;
    [SerializeField] float slopeCheckDistance = 1f;
    [SerializeField] float slopeBoost = 1f;
    [SerializeField] LayerMask groundLayer;
    [SerializeField] LayerMask slopeLayer;
    [SerializeField] LayerMask groundDistanceCheckLayer;

    [SerializeField] private bool isGrounded = false;
    [SerializeField] private bool isAgainstWall = false;
    [SerializeField] private bool isTouchingWallR = false;
    [SerializeField] private bool isTouchingWallL = false;
    [SerializeField] private bool isHeadbonking = false;
    [SerializeField] private bool isOnASlope = false;

    public bool IsGrounded { get { return isGrounded; } }
    public bool IsAgainstWall { get { return isAgainstWall; } }
    public bool IsTouchingWallR { get { return isTouchingWallR; } }
    public bool IsTouchingWallL { get { return isTouchingWallL; } }
    public bool IsHeadbonking { get { return isHeadbonking; } }
    public bool IsOnASlope { get { return isOnASlope; } }

    private bool wasOnASlope = false;

    void Awake()
    {
        player = this.gameObject.GetComponent<PlayerCtrl>();
    }

    void Update()
    {
        GroundCheck();
        SlopeCheck();
        WallCheck();
        HeadbonkCheck();
        wasOnASlope = isOnASlope;
    }

    private void GroundCheck()
    {
        isGrounded = false;
        Collider2D[] colliders = Physics2D.OverlapCircleAll(groundCheckObj.position, groundCheckRadius, groundLayer);
        isGrounded = (colliders.Length > 0);
    }

    private void SlopeCheck()
    {
        isOnASlope = false;
        RaycastHit2D hit = Physics2D.Raycast(groundCheckObj.position, -Vector2.up, slopeCheckDistance, slopeLayer);
        isOnASlope = (hit.collider != null);
        isGrounded = (isGrounded || isOnASlope);

        if (wasOnASlope && !isOnASlope && player.stateMachine.CurrentState != player.stateMachine.jumpingState)
        {
            Vector2 toMove = GetClosestGroundPoint();
            toMove += new Vector2(0f, 1f + groundCheckRadius);
            if (Vector2.Distance(this.transform.position, toMove) <= slopeCheckDistance) { this.transform.position = toMove; }
        }
    }

    private void WallCheck()
    {
        isAgainstWall = false;
        isTouchingWallR = false;
        isTouchingWallL = false;

        bool firstPass = true;
        foreach (Transform t in wallChecksR)
        {
            Collider2D[] collidersR = Physics2D.OverlapCircleAll(t.position, wallCheckRadius, groundLayer);
            isTouchingWallR = (collidersR.Length > 0 && (!firstPass || !isOnASlope));
            if (isTouchingWallR) { break; }
            firstPass = false;
        }

        firstPass = true;
        foreach (Transform t in wallChecksL)
        {
            Collider2D[] collidersL = Physics2D.OverlapCircleAll(t.position, wallCheckRadius, groundLayer);
            isTouchingWallL = (collidersL.Length > 0 && (!firstPass || !isOnASlope));
            if (isTouchingWallL) { break; }
            firstPass = false;
        }

        isAgainstWall = (player.movement.isFacingRight ? isTouchingWallR : isTouchingWallL);
    }

    private void HeadbonkCheck()
    {
        isHeadbonking = false;
        Collider2D[] colliders = Physics2D.OverlapCircleAll(headbonkCheckObj.position + (Vector3.right * (1f / 32f) * (player.movement.isFacingRight ? 1f : -1f)), headbonkCheckRadius, groundLayer);
        isHeadbonking = (colliders.Length > 0);
    }

    public bool CheckDistanceToGround(float minDistance)
    {
        RaycastHit2D hit = Physics2D.Raycast(groundCheckObj.position, -Vector2.up, Mathf.Infinity, groundDistanceCheckLayer);
        return (hit.distance >= minDistance || hit.distance == 0f);
    }

    public Vector2 GetGroundNormal()
    {
        RaycastHit2D hit = Physics2D.Raycast((player.movement.isFacingRight ? normalCheckR : normalCheckL).position, -Vector2.up, slopeCheckDistance, groundDistanceCheckLayer);
        if (hit.collider != null) { return hit.normal; }
        return Vector2.up;
    }

    public Vector2 GetRightVector()
    {
        Vector2 normal = GetGroundNormal();
        if (normal.y != 0f)
        {
            float v1 = 1f;
            float v2 = 0f;
            v2 += (-normal.x);
            v2 /= normal.y;
            Vector2 result = new Vector2(v1, v2);
            result = result.normalized;
            result.x *= (normal != Vector2.up && ((normal.x * (player.movement.isFacingRight ? 1f : -1f)) < 0f) && player.rb2d.velocity.x < player.movement.topSpeed ? slopeBoost : 1f);
            return result;
        }
        return Vector2.right;
    }

    public Vector2 GetClosestGroundPoint()
    {
        RaycastHit2D hit = Physics2D.Raycast(groundCheckObj.position, -Vector2.up, Mathf.Infinity, groundDistanceCheckLayer);
        if (hit.collider != null) { return hit.point; }
        return groundCheckObj.position;
    }
}
