using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MagicBlast : MonoBehaviour
{
    /* COMPONENTS */
    Rigidbody2D rb2d;

    /* DRAG AND DROP */
    [SerializeField] GameObject blastHitboxPrefab;

    /* EDITOR VARIABLES */
    [SerializeField] float fuseTime = 3f;
    [SerializeField] float verticalLaunchSpeed = 1f;
    [SerializeField] float horizontalLaunchSpeed = 2f;
    [SerializeField] float blastDuration = 0.1f;
    [SerializeField] float blastStrength = 3f;
    [SerializeField] float blastRadius = 1.5f;

    /* SCRIPT VARIABLES */
    private float fuseTimeLeft = 0f;

    void Awake()
    {
        rb2d = this.gameObject.GetComponent<Rigidbody2D>();
    }

    void Start()
    {
        fuseTimeLeft = fuseTime;
    }

    void Update()
    {
        fuseTimeLeft -= Time.deltaTime;
        if (fuseTimeLeft <= 0f)
        {
            Detonate();
        }
    }

    public void Detonate()
    {
        GameObject tempObj = Instantiate(blastHitboxPrefab, this.transform.position, Quaternion.identity);
        BlastHitbox tempBlast = tempObj.GetComponent<BlastHitbox>();
        tempBlast.Setup(blastDuration, blastStrength, blastRadius);
        GameObject.Destroy(this.gameObject);
    }

    public void Setup(bool isGoingRight = true, float verticalAxis = 0f)
    {
        rb2d.velocity = new Vector2((isGoingRight ? horizontalLaunchSpeed : -horizontalLaunchSpeed) * (verticalAxis != 0f ? 0.25f : 1f), verticalLaunchSpeed * (verticalAxis > 0f ? 1.5f : 1f) * (verticalAxis < 0f ? 0.5f : 1f));
    }
}
