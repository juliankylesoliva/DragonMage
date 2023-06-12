using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FireMissile : MonoBehaviour
{
    /* EDITOR VARIABLES */
    [SerializeField] DamageType damageType = DamageType.FIRE_MISSILE;
    [SerializeField] float moveSpeed = 6f;
    [SerializeField] float lifetime = 1f;

    /* SCRIPT VARIABLES */
    PlayerTemper temper;
    private float moveSpeedBonus = 0f;
    private float lifetimeLeft = 0f;

    void Awake()
    {
        
    }

    void Start()
    {
        lifetimeLeft = lifetime;
    }

    void Update()
    {
        this.transform.position += (this.transform.right * (moveSpeed + moveSpeedBonus) * Time.deltaTime);

        lifetimeLeft -= Time.deltaTime;
        if (lifetimeLeft <= 0f)
        {
            GameObject.Destroy(this.gameObject);
        }
    }

    public void Setup(PlayerTemper temper, bool isGoingRight = true, float horizontalVelocity = 0f)
    {
        this.temper = temper;
        moveSpeedBonus = Mathf.Abs(horizontalVelocity * 0.5f);
        this.transform.Rotate(0f, 0f, (isGoingRight ? 0f : 180f));
    }

    void OnTriggerEnter2D(Collider2D other)
    {
        MagicBlast tempBlast = other.gameObject.GetComponent<MagicBlast>();
        BreakableBlock block = other.gameObject.GetComponent<BreakableBlock>();
        EnemyBehavior enemy = other.gameObject.GetComponent<EnemyBehavior>();

        if (block != null && (block.breakableBy == BreakableType.ANY || block.breakableBy == BreakableType.FIRE))
        {
            temper.NeutralizeTemperBy(2);
            block.onBreak.Invoke();
        }
        else if (enemy != null)
        {
            if (enemy.DefeatEnemy(damageType))
            {
                temper.NeutralizeTemperBy(2);
            }
        }
        else { /* Nothing */ }
    }
}
