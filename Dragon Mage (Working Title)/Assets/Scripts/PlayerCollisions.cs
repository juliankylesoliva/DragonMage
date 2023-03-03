using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerCollisions : MonoBehaviour
{
    [SerializeField] Transform groundCheckObj;
    [SerializeField] Transform wallCheckR;
    [SerializeField] Transform wallCheckL;
    [SerializeField] Transform headbonkCheckObj;

    [SerializeField] float groundCheckRadius = 0.1f;
    [SerializeField] float wallCheckRadius = 0.1f;
    [SerializeField] float headbonkCheckRadius = 0.5f;
    [SerializeField] LayerMask groundLayer;

    private bool isGrounded = false;
    private bool isAgainstWall = false;
    private bool isTouchingWallR = false;
    private bool isTouchingWallL = false;
    private bool isHeadbonking = false;

    public bool IsGrounded { get { return isGrounded; } }
    public bool IsAgainstWall { get { return isAgainstWall; } }
}
