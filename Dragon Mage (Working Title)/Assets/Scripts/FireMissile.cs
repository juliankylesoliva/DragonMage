using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FireMissile : MonoBehaviour
{
    /* EDITOR VARIABLES */
    [SerializeField] float moveSpeed = 6f;
    [SerializeField] float strafeSpeed = 2f;
    [SerializeField] float lifetime = 8f;
    [SerializeField] float strafeTime = 1f;

    /* SCRIPT VARIABLES */
    private float moveSpeedBonus = 0f;
    private float lifetimeLeft = 0f;
    private float strafeTimeLeft = 0f;

    void Awake()
    {
        
    }

    void Start()
    {
        lifetimeLeft = lifetime;
        strafeTimeLeft = strafeTime;
    }

    void Update()
    {
        this.transform.position += (this.transform.right * (moveSpeed + moveSpeedBonus) * Time.deltaTime);

        if (strafeTimeLeft > 0f)
        {
            Vector3 inputVec = new Vector3(Input.GetAxis("Horizontal"), Input.GetAxis("Vertical"), 0f);
            Vector3 projection = Vector3.Project(inputVec.normalized, this.transform.right);

            this.transform.position += ((inputVec - projection) * strafeSpeed * Time.deltaTime);
            strafeTimeLeft -= Time.deltaTime;
        }

        lifetimeLeft -= Time.deltaTime;
        if (lifetimeLeft <= 0f)
        {
            GameObject.Destroy(this.gameObject);
        }
    }

    public void Setup(bool isGoingRight = true, float horizontalVelocity = 0f, float angle = 0f)
    {
        moveSpeedBonus = Mathf.Abs(horizontalVelocity * 0.5f);
        this.transform.Rotate(0f, 0f, angle);
    }

    void OnTriggerEnter2D(Collider2D col)
    {
        MagicBlast tempBlast = col.gameObject.GetComponent<MagicBlast>();
        if (tempBlast != null)
        {
            tempBlast.AddChargedState();
        }
    }
}
