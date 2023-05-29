using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerSpriteTrail : MonoBehaviour
{
    PlayerCtrl player;

    [SerializeField] GameObject spriteTrailPrefab;
    [SerializeField] float trailSpawnInterval = 0.1f;
    [SerializeField] Color mageTrailColor;
    [SerializeField] Color dragonTrailColor;

    private bool isActive = false;
    private float currentSpawnTimer = 0f;

    void Awake()
    {
        player = this.gameObject.GetComponent<PlayerCtrl>();
    }

    void Start()
    {
        currentSpawnTimer = trailSpawnInterval;
    }

    void Update()
    {
        if (isActive)
        {
            if (currentSpawnTimer > 0f)
            {
                currentSpawnTimer -= Time.deltaTime;
                if (currentSpawnTimer <= 0f)
                {
                    currentSpawnTimer = trailSpawnInterval;
                    GameObject tempObj = Instantiate(spriteTrailPrefab, this.transform.position, Quaternion.identity);
                    SpriteRenderer tempSprite = tempObj.GetComponent<SpriteRenderer>();
                    tempSprite.color = (player.form.currentMode == CharacterMode.MAGE ? mageTrailColor : dragonTrailColor);
                    tempSprite.flipX = player.charSprite.flipX;
                    tempSprite.flipY = player.charSprite.flipY;
                    tempSprite.sortingLayerName = player.charSprite.sortingLayerName;
                    tempSprite.sortingOrder = (player.charSprite.sortingOrder - 1);
                    tempSprite.sprite = player.charSprite.sprite;
                }
            }
        }
    }

    public void ActivateTrail()
    {
        isActive = true;
        currentSpawnTimer = trailSpawnInterval;
    }

    public void DeactivateTrail()
    {
        isActive = false;
    }
}
