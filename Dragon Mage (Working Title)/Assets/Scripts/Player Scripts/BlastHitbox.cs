using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(CircleCollider2D))]
public class BlastHitbox : MonoBehaviour
{
    CircleCollider2D circle;

    [SerializeField] LayerMask impassableLayer;
    [SerializeField] DamageType damageType = DamageType.MAGIC_BLAST;

    private PlayerTemper temper;
    private bool isArmed = false;
    private float hitboxRadius = 0f;
    private float hitboxDuration = 0f;
    private float knockbackStrength = 0f;

    void Awake()
    {
        circle = this.gameObject.GetComponent<CircleCollider2D>();
    }

    void Start()
    {
        SoundFactory.SpawnSound("attack_magli_explosion", this.transform.position, 0.8f);
    }

    void Update()
    {
        if (isArmed)
        {
            hitboxDuration -= Time.deltaTime;
            if (hitboxDuration <= 0f)
            {
                GameObject.Destroy(this.gameObject);
            }
        }
    }

    public void Setup(PlayerTemper temper, float duration, float strength, float radius)
    {
        this.temper = temper;
        isArmed = true;
        hitboxDuration = duration;
        knockbackStrength = strength;
        circle.radius = radius;
        hitboxRadius = radius;
    }

    private bool DoesBlastGoThruWall(Collider2D other)
    {
        Vector3 direction = (other.transform.position - this.transform.position);
        float raycastDistance = Mathf.Min(hitboxRadius, direction.magnitude);
        RaycastHit2D hit = Physics2D.Raycast(this.transform.position, direction.normalized, Mathf.Infinity, impassableLayer);

        return (hit.distance < raycastDistance);
    }

    void OnTriggerEnter2D(Collider2D other)
    {
        Rigidbody2D rb = other.gameObject.GetComponent<Rigidbody2D>();
        BreakableBlock block = other.gameObject.GetComponent<BreakableBlock>();
        PlayerCtrl player = other.gameObject.GetComponent<PlayerCtrl>();
        EnemyBehavior enemy = other.gameObject.GetComponent<EnemyBehavior>();

        if (enemy != null)
        {
            if (!DoesBlastGoThruWall(other) && enemy.DefeatEnemy(damageType))
            {
                temper.NeutralizeTemperBy(-1);
            }
        }
        else if (block != null && !block.isReinforced && (block.breakableBy == BreakableType.ANY || block.breakableBy == BreakableType.MAGIC))
        {
            if (!DoesBlastGoThruWall(other))
            {
                temper.NeutralizeTemperBy(-1);
                block.onBreak.Invoke();
            }
        }
        else { /* Nothing */ }

        if (player != null && player.form.currentMode == CharacterMode.MAGE)
        {
            if (rb != null && rb.bodyType == RigidbodyType2D.Dynamic)
            {
                if (player != null && (player.attacks.isFireTackleActive || player.damage.isPlayerDamaged)) { return; }
                Vector2 velocityVec = (other.transform.position - this.transform.position);
                float distance = velocityVec.magnitude;
                velocityVec = velocityVec.normalized;
                velocityVec *= (knockbackStrength / (1f + distance));
                rb.velocity += velocityVec;
            }
            player.attacks.UseBlastJump();
        }
    }
}
