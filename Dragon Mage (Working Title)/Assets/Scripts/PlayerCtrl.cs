using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerCtrl : MonoBehaviour
{
    /* COMPONENTS */
    Rigidbody2D rb2d;

    /* DRAG AND DROP */
    [Header("Drag and Drop")]
    [SerializeField] Transform groundCheckObj;

    /* EDITOR VARIABLES */
    [Header("Editor Variables")]
    [SerializeField] float groundCheckRadius = 0.1f;
    [SerializeField] LayerMask groundLayer;

    /* RUNNING VARIABLES */
    [Header("Running Variables")]
    [SerializeField, Range(0.01f, 1f)] float acceleration = 0.5f;
    [SerializeField, Range(0.01f, 1f)] float deceleration = 0.5f;
    [SerializeField, Range(2f, 20f)] float topSpeed = 18f;
    [SerializeField, Range(0.01f, 1f)] float turningSpeed = 0.5f;

    /* JUMPING VARIABLES */
    [Header("Jumping Variables")]
    [SerializeField] bool enableAirStalling = true;
    [SerializeField] bool enableVariableJumps = true;
    [SerializeField, Range(2f, 12f)] float jumpSpeed = 4f;
    [SerializeField, Range(0.1f, 10f)] float risingGravity = 1f;
    [SerializeField, Range(0.1f, 10f)] float fallingGravity = 1f;
    [SerializeField, Range(0f, 10f)] float variableJumpDecay = 0.5f;
    [SerializeField, Range(2f, 20f)] float fallSpeed = 6f;
    [SerializeField, Range(0f, 1f)] float airStallSpeed = 1f;
    [SerializeField, Range(0f, 5f)] float maxAirStallTime = 3f;
    [SerializeField, Range(0.01f, 1f)] float airAcceleration = 0.5f;
    [SerializeField, Range(0.01f, 1f)] float airDeceleration = 0.5f;
    [SerializeField, Range(0.01f, 1f)] float airTurningSpeed = 0.5f;
    

    /* SCRIPT VARIABLES */
    private bool isGrounded = false;
    private bool jumpIsHeld = false;
    private float currentAirStallTime = 0f;

    void Awake()
    {
        rb2d = this.gameObject.GetComponent<Rigidbody2D>();
    }

    void Start()
    {

    }

    void Update()
    {
        GroundCheck();
        Jumping();
        Movement();
    }

    /* METHODS */
    private void GroundCheck()
    {
        isGrounded = false;

        Collider2D[] colliders = Physics2D.OverlapCircleAll(groundCheckObj.position, groundCheckRadius, groundLayer);
        isGrounded = (colliders.Length > 0);
    }

    private void Movement()
    {
        if (Input.GetAxis("Horizontal") != 0f)
        {
            if ((rb2d.velocity.x * Input.GetAxis("Horizontal")) >= 0f)
            {
                if (Mathf.Abs(rb2d.velocity.x) < topSpeed)
                {
                    rb2d.velocity = new Vector2(rb2d.velocity.x + ((isGrounded ? acceleration : airAcceleration) * (Input.GetAxis("Horizontal") > 0f ? 1f : -1f)), rb2d.velocity.y);
                    if (Mathf.Abs(rb2d.velocity.x) > topSpeed)
                    {
                        rb2d.velocity = new Vector2(topSpeed * (Input.GetAxis("Horizontal") > 0f ? 1f : -1f), rb2d.velocity.y);
                    }
                }
            }
            else
            {
                if (rb2d.velocity.x != 0f)
                {
                    rb2d.velocity = new Vector2(rb2d.velocity.x + ((isGrounded ? turningSpeed : airTurningSpeed) * (Input.GetAxis("Horizontal") > 0f ? 1f : -1f)), rb2d.velocity.y);
                }
            }
        }
        else
        {
            if (rb2d.velocity.x > 0f)
            {
                rb2d.velocity = new Vector2(rb2d.velocity.x - (isGrounded ? deceleration : airDeceleration), rb2d.velocity.y);
                if (rb2d.velocity.x < 0f)
                {
                    rb2d.velocity = new Vector2(0f, rb2d.velocity.y);
                }
            }
            else if (rb2d.velocity.x < 0f)
            {
                rb2d.velocity = new Vector2(rb2d.velocity.x + (isGrounded ? deceleration : airDeceleration), rb2d.velocity.y);
                if (rb2d.velocity.x > 0f)
                {
                    rb2d.velocity = new Vector2(0f, rb2d.velocity.y);
                }
            }
            else { /* Nothing */ }
        }
    }

    private void Jumping()
    {
        if (isGrounded)
        {
            currentAirStallTime = 0f;

            if (Input.GetButtonDown("Jump"))
            {
                jumpIsHeld = true;
                rb2d.gravityScale = risingGravity;
                rb2d.velocity = new Vector2(rb2d.velocity.x, jumpSpeed);
            }
        }
        else
        {
            if (rb2d.velocity.y > 0f)
            {
                rb2d.gravityScale = risingGravity;

                if (jumpIsHeld && !Input.GetButton("Jump"))
                {
                    jumpIsHeld = false;
                }

                if (enableVariableJumps && !jumpIsHeld)
                {
                    rb2d.velocity = new Vector2(rb2d.velocity.x, rb2d.velocity.y - variableJumpDecay);
                }
            }
            else
            {
                jumpIsHeld = false;

                if (enableAirStalling && currentAirStallTime < maxAirStallTime && Input.GetButton("Jump"))
                {
                    rb2d.gravityScale = 0f;
                    rb2d.velocity = new Vector2(rb2d.velocity.x, -airStallSpeed);
                    currentAirStallTime += Time.deltaTime;
                }
                else
                {
                    rb2d.gravityScale = fallingGravity;

                    if (currentAirStallTime > 0f)
                    {
                        currentAirStallTime = maxAirStallTime;
                    }

                    if (rb2d.velocity.y < -fallSpeed)
                    {
                        rb2d.velocity = new Vector2(rb2d.velocity.x, -fallSpeed);
                    }
                }
            }
        }
    }
}
