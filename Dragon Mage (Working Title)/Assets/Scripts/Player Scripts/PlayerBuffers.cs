using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerBuffers : MonoBehaviour
{
    PlayerCtrl player;

    [SerializeField] float formChangeBufferTime = 0.1f;
    [SerializeField] float jumpBufferTime = 0.1f;
    [SerializeField] float highestSpeedBufferTime = 0.1f;
    [SerializeField] float coyoteTime = 0.1f;
    [SerializeField] float earlyGlideBufferTime = 0.25f;

    public float EarlyGlideBufferTime { get { return earlyGlideBufferTime; } }
    public float highestSpeedBufferTimeLeft { get; private set; }

    public float formChangeBufferTimeLeft { get; private set; }
    public void ResetFormChangeBuffer() { formChangeBufferTimeLeft = 0f; }

    public float jumpBufferTimeLeft { get; private set; }
    public void ResetJumpBuffer() { jumpBufferTimeLeft = 0f; }

    public float highestSpeedBuffer { get; private set; }
    public float coyoteTimeLeft { get; private set; }

    void Awake()
    {
        player = this.gameObject.GetComponent<PlayerCtrl>();
    }

    void Start()
    {
        StartCoroutine(JumpBufferCR());
        StartCoroutine(FormChangeBufferCR());
        StartCoroutine(HighestSpeedBufferCR());
        StartCoroutine(CoyoteTimeCR());
    }

    private IEnumerator JumpBufferCR()
    {
        while (true)
        {
            if (player.jumpButtonDown)
            {
                jumpBufferTimeLeft = jumpBufferTime;
            }

            if (jumpBufferTimeLeft > 0f)
            {
                jumpBufferTimeLeft -= Time.deltaTime;
                if (jumpBufferTimeLeft < 0f)
                {
                    jumpBufferTimeLeft = 0f;
                }
            }

            yield return null;
        }
    }

    private IEnumerator FormChangeBufferCR()
    {
        while (true)
        {
            if (player.formChangeButtonDown)
            {
                formChangeBufferTimeLeft = formChangeBufferTime;
            }

            if (formChangeBufferTimeLeft > 0f)
            {
                formChangeBufferTimeLeft -= Time.deltaTime;
                if (formChangeBufferTimeLeft < 0f)
                {
                    formChangeBufferTimeLeft = 0;
                }
            }

            yield return null;
        }
    }

    private IEnumerator HighestSpeedBufferCR()
    {
        highestSpeedBufferTimeLeft = highestSpeedBufferTime;
        while (true)
        {
            float currentHorizontalSpeed = (player.jumping.currentWallClimbTime > 0f && player.jumping.currentWallClimbTime < player.jumping.maxWallClimbTime ? Mathf.Max(player.jumping.storedWallClimbSpeed, Mathf.Abs(player.rb2d.velocity.x)) : Mathf.Abs(player.rb2d.velocity.x));

            if (currentHorizontalSpeed >= highestSpeedBuffer)
            {
                highestSpeedBuffer = currentHorizontalSpeed;
                highestSpeedBufferTimeLeft = highestSpeedBufferTime;
            }
            else
            {
                if (!player.form.isChangingForm)
                {
                    if (highestSpeedBufferTimeLeft > 0f && (player.collisions.IsGrounded || player.collisions.IsOnASlope || player.collisions.IsAgainstWall)) { highestSpeedBufferTimeLeft -= Time.deltaTime; }

                    if (highestSpeedBufferTimeLeft <= 0f)
                    {
                        highestSpeedBufferTimeLeft = 0f;
                        highestSpeedBuffer = currentHorizontalSpeed;
                    }
                }
            }

            yield return null;
        }
    }

    public void ResetSpeedBuffer()
    {
        highestSpeedBufferTimeLeft = 0f;
    }

    private IEnumerator CoyoteTimeCR()
    {
        bool prevIsGrounded = player.collisions.IsGrounded;
        while (true)
        {
            if (!player.collisions.IsGrounded && prevIsGrounded && coyoteTimeLeft <= 0f && player.rb2d.velocity.y < 0f)
            {
                coyoteTimeLeft = coyoteTime;
            }
            else if (((player.collisions.IsGrounded || player.collisions.IsOnASlope) && !prevIsGrounded) || ((player.collisions.IsGrounded || player.collisions.IsOnASlope) && prevIsGrounded))
            {
                coyoteTimeLeft = 0f;
            }
            else { /* Nothing */ }

            if (coyoteTimeLeft > 0f)
            {
                coyoteTimeLeft -= Time.deltaTime;
                if (coyoteTimeLeft < 0f)
                {
                    coyoteTimeLeft = 0f;
                }
            }

            prevIsGrounded = (player.collisions.IsGrounded || player.collisions.IsOnASlope);

            yield return null;
        }
    }
}
