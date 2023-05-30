using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerDamage : MonoBehaviour
{
    PlayerCtrl player;

    [SerializeField] float baseVerticalKnockback = 2f;
    [SerializeField] float baseHorizontalKnockback = 5f;
    [SerializeField] float baseHitstunTime = 1f;
    [SerializeField] float knockbackMagnitudeEpsilon = 0.001f;
    [SerializeField] PhysicsMaterial2D normalMaterial;
    [SerializeField] PhysicsMaterial2D damagedMaterial;

    private Transform damageSource = null;
    private float hitstunTimer = 0f;
    public bool isPlayerDamaged { get { return hitstunTimer > 0f; } }

    void Awake()
    {
        player = this.gameObject.GetComponent<PlayerCtrl>();
    }

    public void TakeDamage(Transform source)
    {
        if (hitstunTimer > 0f || !CanTakeDamage()) { return; }
        damageSource = source;
        StartCoroutine(HitstunTimerCR(baseHitstunTime));
        player.temper.ChangeTemperBy(player.form.currentMode == CharacterMode.MAGE ? 2 : 1);
    }

    public void DoKnockback()
    {
        if (damageSource == null) { return; }

        Vector3 playerPos = this.transform.position;
        Vector3 damageSrcPos = damageSource.position;
        float xDiff = (playerPos.x - damageSrcPos.x);
        float horizontalDirection = (xDiff > 0f ? 1f : -1f);

        player.rb2d.gravityScale = player.jumping.fallingGravity;
        Vector2 newVelocity = new Vector2(horizontalDirection * baseHorizontalKnockback, baseVerticalKnockback);
        player.rb2d.velocity = newVelocity;

        damageSource = null;
    }

    private bool CanTakeDamage()
    {
        string currentState = player.stateMachine.CurrentState.name;
        return (currentState != "FireTackling" && currentState != "FormChanging" && currentState != "Damaged");
    }

    private IEnumerator HitstunTimerCR(float time)
    {
        if (hitstunTimer > 0f) { yield break; }

        hitstunTimer = time;
        player.rb2d.sharedMaterial = damagedMaterial;

        while (player.stateMachine.CurrentState != player.stateMachine.damagedState) { yield return null; }
        while (!player.collisions.IsGrounded || player.rb2d.velocity.magnitude >= knockbackMagnitudeEpsilon) { yield return null; }

        player.rb2d.sharedMaterial = normalMaterial;
        player.rb2d.velocity = Vector2.zero;
        player.collisions.SnapToGround();

        while (hitstunTimer > 0f)
        {
            hitstunTimer -= Time.deltaTime;
            if (hitstunTimer < 0f)
            {
                hitstunTimer = 0f;
            }
            yield return null;
        }
        
    }
}
