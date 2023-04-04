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

    [SerializeField] float groundCheckRadius = 0.1f;
    [SerializeField] float wallCheckRadius = 0.1f;
    [SerializeField] float headbonkCheckRadius = 0.5f;
    [SerializeField] LayerMask groundLayer;

    [SerializeField] private bool isGrounded = false;
    [SerializeField] private bool isAgainstWall = false;
    [SerializeField] private bool isTouchingWallR = false;
    [SerializeField] private bool isTouchingWallL = false;
    [SerializeField] private bool isHeadbonking = false;

    public bool IsGrounded { get { return isGrounded; } }
    public bool IsAgainstWall { get { return isAgainstWall; } }
    public bool IsTouchingWallR { get { return isTouchingWallR; } }
    public bool IsTouchingWallL { get { return isTouchingWallL; } }
    public bool IsHeadbonking { get { return isHeadbonking; } }

    void Awake()
    {
        player = this.gameObject.GetComponent<PlayerCtrl>();
    }

    void Update()
    {
        GroundCheck();
        WallCheck();
        HeadbonkCheck();
    }

    private void GroundCheck()
    {
        isGrounded = false;
        Collider2D[] colliders = Physics2D.OverlapCircleAll(groundCheckObj.position, groundCheckRadius, groundLayer);
        isGrounded = (colliders.Length > 0);
    }

    private void WallCheck()
    {
        isAgainstWall = false;
        isTouchingWallR = false;
        isTouchingWallL = false;

        
        foreach (Transform t in wallChecksR)
        {
            Collider2D[] collidersR = Physics2D.OverlapCircleAll(t.position, wallCheckRadius, groundLayer);
            isTouchingWallR = (collidersR.Length > 0);
            if (isTouchingWallR) { break; }
        }

        foreach (Transform t in wallChecksL)
        {
            Collider2D[] collidersL = Physics2D.OverlapCircleAll(t.position, wallCheckRadius, groundLayer);
            isTouchingWallL = (collidersL.Length > 0);
            if (isTouchingWallL) { break; }
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
        RaycastHit2D hit = Physics2D.Raycast(groundCheckObj.position, -Vector2.up, Mathf.Infinity, groundLayer);
        return (hit.distance >= minDistance || hit.distance == 0f);
    }
}
