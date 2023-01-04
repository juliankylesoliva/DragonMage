using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FireMissile : MonoBehaviour
{
    /* COMPONENTS */
    Rigidbody2D rb2d;

    /* EDITOR VARIABLES */
    [SerializeField] float moveSpeed = 6f;
    [SerializeField] float lifetime = 8f;

    /* SCRIPT VARIABLES */
    private float moveSpeedBonus = 0f;
    private float lifetimeLeft = 0f;

    void Awake()
    {
        rb2d = this.gameObject.GetComponent<Rigidbody2D>();
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

    public void Setup(bool isGoingRight = true, float velocityMagnitude = 0f, float angle = 0f)
    {
        moveSpeedBonus = (velocityMagnitude * 0.5f);
        this.transform.Rotate(0f, 0f, angle);
    }
}
