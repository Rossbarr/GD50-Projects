using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Helicopter : MonoBehaviour
{
    public float speed= 10.0f;
    public int coinTotal = 0;
    public float yLimitBottom = -21f;
    public float yLimitTop = 21f;
    public float zLimitLeft = -21f;
    public float zLimitRight = 21f;
    public ParticleSystem explosion;
    public AudioSource explosionSound;
    AudioSource coinPickupSFX;
    ParticleSystem coinPickupVFX;

    float vertical, horizontal;    
    Rigidbody rb;

    // Start is called before the first frame update
    void Start()
    {
        rb = GetComponent<Rigidbody>();
        coinPickupSFX = GetComponents<AudioSource>()[0];
        coinPickupVFX = GetComponent<ParticleSystem>();
    }

    // Update is called once per frame
    void Update()
    {
        Move();
    }

    public void PickupCoin()
    {
        coinTotal += 1;

        coinPickupSFX.Play();
        coinPickupVFX.Play();
    }

    public void Explode()
    {
        explosionSound.Play();

        ParticleSystem deathVFX = Instantiate(explosion, transform.position, Quaternion.identity);
        deathVFX.Play();

        Destroy(gameObject);
    }


    void Move()
    {
        if (Input.GetAxisRaw("Vertical") != 0)
        {
            vertical = Input.GetAxis("Vertical") * speed;

            if (transform.position.y <= yLimitBottom)
            {
				transform.position = new Vector3(transform.position.x, yLimitBottom, transform.position.z);
			}
			if (transform.position.y >= yLimitTop)
            {
				transform.position = new Vector3(transform.position.x, yLimitTop, transform.position.z);
			}
        }
        else
        {
            vertical = 0f;
        }

        if (Input.GetAxisRaw("Horizontal") != 0)
        {
            horizontal = Input.GetAxis("Horizontal") * speed;

            if (transform.position.z <= zLimitLeft)
            {
				transform.position = new Vector3(transform.position.x, transform.position.y, zLimitLeft);
			}
			if (transform.position.z >= zLimitRight)
            {
				transform.position = new Vector3(transform.position.x, transform.position.y, zLimitRight);
			}
        }
        else
        {
            horizontal = 0f;
        }

        rb.velocity = new Vector3(0, vertical, horizontal);

    }
}
