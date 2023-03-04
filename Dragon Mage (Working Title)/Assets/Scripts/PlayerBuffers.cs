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

    [HideInInspector] public float formChangeBufferTimeLeft = 0f;
    [HideInInspector] public float jumpBufferTimeLeft = 0f;
    [HideInInspector] public float highestSpeedBuffer = 0f;
    [HideInInspector] public float coyoteTimeLeft = 0f;

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
            if (Input.GetButtonDown("Jump"))
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
            if (Input.GetButtonDown("Change Form"))
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
        float highestSpeedBufferTimeLeft = highestSpeedBufferTime;
        while (true)
        {
            float currentHorizontalSpeed = (player.currentWallClimbTime > 0f && player.currentWallClimbTime < player.maxWallClimbTime ? Mathf.Max(player.storedWallClimbSpeed, Mathf.Abs(player.rb2d.velocity.x)) : Mathf.Abs(player.rb2d.velocity.x));

            if (currentHorizontalSpeed > highestSpeedBuffer)
            {
                highestSpeedBuffer = currentHorizontalSpeed;
                highestSpeedBufferTimeLeft = highestSpeedBufferTime;
            }
            else if (currentHorizontalSpeed < highestSpeedBuffer)
            {
                if (!player.isChangingForm)
                {
                    if (highestSpeedBufferTimeLeft > 0f) { highestSpeedBufferTimeLeft -= Time.deltaTime; }

                    if (highestSpeedBufferTimeLeft <= 0f)
                    {
                        highestSpeedBufferTimeLeft = 0f;
                        highestSpeedBuffer = currentHorizontalSpeed;
                    }
                }
            }
            else { /* Nothing */ }

            yield return null;
        }
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
            else if ((player.collisions.IsGrounded && !prevIsGrounded) || (player.collisions.IsGrounded && prevIsGrounded))
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

            prevIsGrounded = player.collisions.IsGrounded;

            yield return null;
        }
    }
}
