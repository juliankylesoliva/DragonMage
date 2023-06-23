using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerDamage : MonoBehaviour
{
    PlayerCtrl player;

    [SerializeField] int mageTemperDamage = 2;
    [SerializeField] int dragonTemperDamage = -1;
    [SerializeField] float baseVerticalKnockback = 2f;
    [SerializeField] float baseHorizontalKnockback = 5f;
    [SerializeField] float baseHitstunTime = 1f;
    [SerializeField] float knockbackMagnitudeEpsilon = 0.001f;
    [SerializeField] float postDamageInvulnerabilityTime = 3f;
    [SerializeField, Range(0f, 1f)] float invulnerabilityAlpha = 0.75f;
    [SerializeField] PhysicsMaterial2D normalMaterial;
    [SerializeField] PhysicsMaterial2D damagedMaterial;

    private Transform damageSource = null;
    private float hitstunTimer = 0f;
    private bool isDamageInvulnerabilityActive = false;
    private bool isDamageInvulnerabilityFlickering = false;

    public bool isPlayerDamaged { get { return hitstunTimer > 0f; } }

    void Awake()
    {
        player = this.gameObject.GetComponent<PlayerCtrl>();
    }

    void Update()
    {
        if (!PauseHandler.isPaused)
        {
            Color spriteColor = player.charSprite.color;
            if (isDamageInvulnerabilityActive && isDamageInvulnerabilityFlickering)
            {
                spriteColor.a = invulnerabilityAlpha;
            }
            else
            {
                spriteColor.a = 1f;
            }
            player.charSprite.color = spriteColor;
            isDamageInvulnerabilityFlickering = !isDamageInvulnerabilityFlickering;
        }
    }

    public void TakeDamage(Transform source)
    {
        if (hitstunTimer > 0f || !CanTakeDamage()) { return; }
        damageSource = source;
        StartCoroutine(HitstunTimerCR(baseHitstunTime));
        player.temper.ChangeTemperBy(player.form.currentMode == CharacterMode.MAGE ? mageTemperDamage : dragonTemperDamage);
        MedalFragment.DropFragments();
        player.sfxCtrl.PlaySound("damage_player");
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

    public void DoIFrames()
    {
        if (isDamageInvulnerabilityActive) { return; }
        StartCoroutine(PostDamageIFramesCR(postDamageInvulnerabilityTime));
    }

    private bool CanTakeDamage()
    {
        string currentState = player.stateMachine.CurrentState.name;
        return (!isDamageInvulnerabilityActive && !player.attacks.isBlastJumpActive && player.attacks.currentAttackState != AttackState.ACTIVE && currentState != "FormChanging" && currentState != "Damaged");
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

    private IEnumerator PostDamageIFramesCR(float time)
    {
        if (isDamageInvulnerabilityActive) { yield break; }

        isDamageInvulnerabilityFlickering = false;

        isDamageInvulnerabilityActive = true;
        yield return new WaitForSeconds(time);
        isDamageInvulnerabilityActive = false;
    }
}
